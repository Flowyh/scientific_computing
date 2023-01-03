#=
  Główny moduł zawierający implementację metod rozwiązywania układów równań liniowych.
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal5l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 29.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#


module blocksys

  # Export all functions
  export  BlockSparseMatrix,
          BlockSparseMatrixStats,
          BlockSparseMatrixValue,
          first_nonzero_column,
          last_nonzero_column,
          first_nonzero_row,
          last_nonzero_row,
          get_b_vector, 
          gauss_no_pivoting!,
          gauss_partial_pivoting!,
          lu_no_pivoting!,
          lu_partial_pivoting!,
          solve_lu_no_pivoting!,
          compute_and_solve_lu_no_pivoting!,
          solve_lu_partial_pivoting!,
          compute_and_solve_lu_partial_pivoting!


  #===================================#
  # Block sparse matrix helper struct #
  #===================================#

  # Keeps track of how many times matrix values were accessed/modified
  mutable struct BlockSparseMatrixStats
    no_getindex::Int64
    no_setindex::Int64
  end

  # Print BlockSparseMatrixStats struct in a nice way
  function Base.show(io::IO, stats::BlockSparseMatrixStats)
    println(io, "Matrix observability stats:")
    println(io, "  Matrix values accesses: $(stats.no_getindex)")
    print(io, "  Matrix values setting: $(stats.no_setindex)")
  end
  
  # Type alias
  const BlockSparseMatrixValue = Tuple{Int64, Int64, Float64}


  # Block sparse matrix struct
  # It is an optimized structure for storing our special kind of matrices
  # which were described in the task.
  #
  # It is a matrix of size n x n, where n is divisible by l.
  # It is divided into blocks of size l x l.
  # There are 3 kinds of blocks:
  #  - A: full blocks (all values are non-zero)
  #  - B: first row and last column blocks (all values are non-zero, but only on the first row and last column)
  #  - C: diagonal blocks (all values are non-zero, but only on the diagonal)
  # The matrix has a below structure:
  # [A_1, C_1, 0, 0, 0,   ..., 0]
  # [B_2, A_2, C_2, 0, 0, ..., 0]
  # [0, B_3, A_3, C_3, 0, ..., 0]
  # [0, 0, B_4, A_4, C_4, ..., 0]
  # ...
  # [0, 0, 0, 0, 0, ..., B_n/l, A_n/l]
  # Where A_i, B_i, C_i are blocks of size l x l.
  # We can take advantage of this structure and compute the range of non-zero values for each
  # row and column. This way we can store only non-zero values in a vector and access them
  # in O(1) time.
  #
  # The matrix is stored in a vector of vectors, where each vector is a row of the matrix.
  # The inside vector stores only the non-zero values, which means that we have to offset when accessing
  # the correct value.
  #
  # When accessing/modifying a value, we will be offsetting the index by the first non-zero
  # column of the row, so that we can access the correct value in the vector.
  # This means, that if we access a value which is out of the range of non-zero values,
  # we will simply return 0.
  mutable struct BlockSparseMatrix
    values::Vector{Vector{Float64}} # Vector of rows, there will be exactly n of them
    n::Int64 # Size of the matrix
    l::Int64 # Size of the blocks
    no_blocks::Int64 # Number of blocks
    row_ranges::Dict{Int64, UnitRange} # Dictionary of ranges of non-zero values for each row
    col_ranges::Dict{Int64, UnitRange} # Dictionary of ranges of non-zero values for each column
    observability::BlockSparseMatrixStats # Access/modify stats

    # Constructor
    function BlockSparseMatrix(
      n::Int64, 
      l::Int64, 
      values::Vector{BlockSparseMatrixValue}
    )
      if (n % l != 0)
        throw(DomainError("n must be divisible by l"))
      end

      no_blocks = n ÷ l

      row_ranges::Dict{Int64, UnitRange} = Dict()
      col_ranges::Dict{Int64, UnitRange} = Dict()

      # Use the helper functions to compute the ranges of non-zero values
      for i in 1:n
        row_ranges[i] = first_nonzero_column(l, i):last_nonzero_column(n, l, i)
        col_ranges[i] = first_nonzero_row(l, i):last_nonzero_row(n, l, i)
      end

      matrix::Vector{Vector{Float64}} = []
      for i in 1:n
        push!(matrix, zeros(length(row_ranges[i])))
      end
      
      # Offset the indices by the first non-zero column of the row
      for (row, col, value) in values
        matrix[row][col - row_ranges[row].start + 1] = value
      end

      return new(
        matrix,
        n,
        l,
        no_blocks,
        row_ranges,
        col_ranges,
        BlockSparseMatrixStats(0, 0)
      )
    end
  end


  """
      Base.getindex(matrix::BlockSparseMatrix, row::Int64, column::Int64)::Float64

  Get the value at the given row and column.
  If the value is out of the range of non-zero values, return 0.

  Because of precomputed ranges of non-zero values, we get O(1) value access time.

  ## Arguments
  - `matrix`: The matrix to get the value from
  - `row`: The row of the value
  - `column`: The column of the value

  ## Returns
  - `Float64`: The value at the given row and column.
  """
  function Base.getindex(
    matrix::BlockSparseMatrix,
    row::Int64,
    column::Int64
  )::Float64
    matrix.observability.no_getindex += 1
    
    if !(column in matrix.row_ranges[row])
      return 0.0
    end

    # Offset the index by the first non-zero column of the row
    return matrix.values[row][column - matrix.row_ranges[row].start + 1]
  end


  """
      Base.setindex!(matrix::BlockSparseMatrix, value::Float64, row::Int64, column::Int64)
  
  Set the value at the given row and column.
  If the value is out of the range of non-zero values, add it to the end of the row.

  Because of precomputed ranges of non-zero values, we get O(1) value access time.

  ## Arguments
  - `matrix`: The matrix to set the value in
  - `value`: The value to set
  - `row`: The row of the value
  - `column`: The column of the value
  """
  function Base.setindex!(
    matrix::BlockSparseMatrix,
    value::Float64,
    row::Int64,
    column::Int64
  )
    matrix.observability.no_setindex += 1

    # Because of the way we store the matrix, we need to add the value to the end of the row
    # if it is out of the range of non-zero values.
    # Of course it should happen only if we are accessing row_range+1
    # element, but we know that the algorithms implemented below will not access
    # values which are further than 1 away from the range of non-zero values.
    # (Tested empirically)
    if !(column in matrix.row_ranges[row])
      push!(matrix.values[row], 0.)
      matrix.row_ranges[row] = matrix.row_ranges[row].start:matrix.row_ranges[row].stop+1
    end
    
    # Offset the index by the first non-zero column of the row
    matrix.values[row][column - matrix.row_ranges[row].start + 1] = value
  end


  """
      first_nonzero_column(l::Int64, row::Int64)::Int64
  
  Get the first column which is non-zero for the given row.

  ## Arguments
  - `l`: The size of the blocks
  - `row`: The row to get the first non-zero column for

  ## Returns
  - `Int64`: The first non-zero column for the given row
  """
  function first_nonzero_column(l::Int64, row::Int64)::Int64
    if ((row - 1) % l == 0)
      return max(1, row - l)
    end

    return max(1, fld(row - 1, l) * l)
  end
  

  """
      last_nonzero_column(n::Int64, l::Int64, row::Int64)::Int64
  
  Get the last column which is non-zero for the given row.

  ## Arguments
  - `n`: The size of the matrix
  - `l`: The size of the blocks
  - `row`: The row to get the last non-zero column for

  ## Returns
  - `Int64`: The last non-zero column for the given row
  """
  function last_nonzero_column(n::Int64, l::Int64, row::Int64)::Int64
    return min(n, row + l)
  end
  

  """
      first_nonzero_row(l::Int64, col::Int64)::Int64
  
  Get the first row which is non-zero for the given column.

  ## Arguments
  - `l`: The size of the blocks
  - `col`: The column to get the first non-zero row for

  ## Returns
  - `Int64`: The first non-zero row for the given column
  """
  function first_nonzero_row(l::Int64, col::Int64)::Int64
    return max(col - l, 1)
  end
  

  """
      last_nonzero_row(n::Int64, l::Int64, col::Int64)::Int64
  
  Get the last row which is non-zero for the given column.

  ## Arguments
  - `n`: The size of the matrix
  - `l`: The size of the blocks
  - `col`: The column to get the last non-zero row for

  ## Returns
  - `Int64`: The last non-zero row for the given column
  """
  function last_nonzero_row(n::Int64, l::Int64, col::Int64)::Int64
    k = col
    return min(n, k % l == 0 ? k + l : cld(k, l) * l + 1)
  end


  """
      Base.:*(matrix::BlockSparseMatrix, vec::Vector{Float64})::Vector{Float64}
  
  Multiply the matrix by the vector.
  Optimized for our matrix structure.

  ## Arguments
  - `matrix`: The matrix to multiply
  - `vec`: The vector to multiply by

  ## Returns
  - `Vector{Float64}`: The result of the multiplication
  """
  function Base.:*(matrix::BlockSparseMatrix, vec::Vector{Float64})::Vector{Float64}
    if (length(vec) != matrix.n)
      throw(DimensionMismatch("Matrix and vector dimensions do not match"))
    end

    result = zeros(Float64, matrix.n)
    for row in 1:matrix.n
      for col in matrix.row_ranges[row] # Omit empty columns
        result[row] += matrix[row, col] * vec[col]
      end
    end

    return result
  end


  """
      get_b_vector(matrix::BlockSparseMatrix)::Vector{Float64}
  
  Get the vector b from the matrix, assuming that x = (1, 1, 1, ...).

  ## Arguments
  - `matrix`: The matrix to get the vector b from

  ## Returns
  - `Vector{Float64}`: The vector b
  """
  function get_b_vector(matrix::BlockSparseMatrix)::Vector{Float64}
    b = zeros(Float64, matrix.n)
    for row in 1:matrix.n
      for col in matrix.row_ranges[row] 
        b[row] += matrix[row, col]
      end
    end
    return b
  end


  #==========================#
  # Solving linear equations #
  #==========================#


  """
      gauss_no_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}

  Solve the linear equation system Ax = b using Gauss elimination without pivoting.
  The matrix A is modified in the process.

  ## Arguments
  - `matrix`: The matrix A
  - `b`: The vector b

  ## Returns
  - `Vector{Float64}`: The solution vector x
  """
  function gauss_no_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}
    if (matrix.n != length(b))
      throw(DimensionMismatch("Matrix and vector dimensions do not match"))
    end

    # Forward elimination
    for col in 1:matrix.n-1
      for row in col+1:matrix.col_ranges[col].stop
        if isapprox(matrix[col, col], 0.)
          throw(DomainError("Matrix has zero on diagonal: $(matrix[col, col])])"))
        end
        l = matrix[row, col] / matrix[col, col]
        matrix[row, col] = 0.
        for changed_col in col+1:matrix.row_ranges[row].stop # We are going through the diagonal, so row = col
          matrix[row, changed_col] -= l * matrix[col, changed_col]
        end

        b[row] -= l * b[col]
      end
    end

    # Backward substitution
    xs = b[1:end]
    for row in matrix.n:-1:1
      for col in row+1:matrix.row_ranges[row].stop
        xs[row] -= matrix[row, col] * xs[col]
      end
      xs[row] /= matrix[row, row]
    end

    return xs
  end


  """
      gauss_partial_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}
  
  Solve the linear equation system Ax = b using Gauss elimination with partial pivoting.
  The matrix A is modified in the process.

  ## Arguments
  - `matrix`: The matrix A
  - `b`: The vector b

  ## Returns
  - `Vector{Float64}`: The solution vector x
  """
  function gauss_partial_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}
    if (matrix.n != length(b))
      throw(DimensionMismatch("Matrix and vector dimensions do not match"))
    end

    # Permutation vector
    permutation = collect(1:matrix.n)

    # Forward elimination
    for col in 1:matrix.n-1
      # Search for the largest element in the column
      max_row_index = col
      for row in col+1:matrix.col_ranges[col].stop
        if (abs(matrix[row, col]) > abs(matrix[max_row_index, col]))
          max_row_index = row
        end
      end

      # Instead of swapping rows, we swap rows in permutation vector
      # Later we will use permutation vector to access rows in matrix
      if (max_row_index != col)
        permutation[col], permutation[max_row_index] = permutation[max_row_index], permutation[col]
      end

      for row in col+1:matrix.col_ranges[col].stop
        if (permutation[row] == max_row_index)
          continue
        end
        l = matrix[permutation[row], col] / matrix[permutation[col], col]
        matrix[permutation[row], col] = 0.
        # In pivoting we are searching for the largest element in the column.
        # At most matrix.l elements are nonzero below current element.
        # This means that we can have at most col + 2matrix.l nonzero elements in the row.
        # Therefore we have to shift searching for last nonzero column by + matrix.l
        for changed_col in col+1:last_nonzero_column(matrix.n, matrix.l, col + matrix.l)
          matrix[permutation[row], changed_col] -= l * matrix[permutation[col], changed_col]
        end

        b[permutation[row]] -= l * b[permutation[col]]
      end
    end

    # Backward substitution
    xs = zeros(Float64, matrix.n)
    for row in matrix.n:-1:1
      xs[row] = b[permutation[row]]
      for col in row+1:last_nonzero_column(matrix.n, matrix.l, row + matrix.l)
        xs[row] -= matrix[permutation[row], col] * xs[col]
      end
      xs[row] /= matrix[permutation[row], row]
    end

    return xs
  end


  #==================#
  # LU decomposition #
  #==================#


  """
      lu_no_pivoting!(matrix::BlockSparseMatrix)
  
  LU decomposition of the matrix A using Gauss elimination without pivoting.
  The matrix A is modified in the process.

  ## Arguments
  - `matrix`: The matrix A
  """
  function lu_no_pivoting!(matrix::BlockSparseMatrix)
    for col in 1:matrix.n-1
      for row in col+1:matrix.col_ranges[col].stop
        if isapprox(matrix[col, col], 0.)
          throw(DomainError("Matrix has zero on diagonal: $(matrix[col, col])])"))
        end
        low = matrix[row, col] / matrix[col, col]
        matrix[row, col] = low
        for changed_col in col+1:matrix.row_ranges[row].stop # We are going through the diagonal, so row = col
          matrix[row, changed_col] -= low  * matrix[col, changed_col]
        end
      end
    end
  end


  """
      lu_partial_pivoting!(matrix::BlockSparseMatrix)::Vector{Int64}

  LU decomposition of the matrix A using Gauss elimination with partial pivoting.
  The matrix A is modified in the process.

  ## Arguments
  - `matrix`: The matrix A

  ## Returns
  - `Vector{Int64}`: The permutation vector
  """
  function lu_partial_pivoting!(matrix::BlockSparseMatrix)::Vector{Int64}
    permutation = collect(1:matrix.n)

    for col in 1:matrix.n-1
      # Search for the largest element in the column
      max_row_index = col
      for row in col+1:matrix.col_ranges[col].stop
        if (abs(matrix[row, col]) > abs(matrix[max_row_index, col]))
          max_row_index = row
        end
      end

      # Instead of swapping rows, we swap rows in permutation vector
      # Later we will use permutation vector to access rows in matrix
      if (max_row_index != col)
        permutation[col], permutation[max_row_index] = permutation[max_row_index], permutation[col]
      end

      for row in col+1:matrix.col_ranges[col].stop
        low = matrix[permutation[row], col] / matrix[permutation[col], col]
        matrix[permutation[row], col] = low
        # In pivoting we are searching for the largest element in the column.
        # At most matrix.l elements are nonzero below current row.
        # This means that we can have at most col + 2matrix.l nonzero elements in the row.
        # Therefore we have to shift searching for last nonzero column by +matrix.l
        for changed_col in col+1:last_nonzero_column(matrix.n, matrix.l, col + matrix.l)
          matrix[permutation[row], changed_col] -= low * matrix[permutation[col], changed_col]
        end
      end
    end

    return permutation
  end


  #=================#
  # Solving with LU #
  #=================#


  """
      solve_lu_no_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}
    
  Solves the system Ax = b using LU decomposition without pivoting.
  The matrix A is modified in the process.

  ## Arguments
  - `matrix`: The matrix A
  - `b`: The vector b

  ## Returns
  - `Vector{Float64}`: The solution vector x
  """
  function solve_lu_no_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}
    if (matrix.n != length(b))
      throw(DimensionMismatch("Matrix and vector dimensions do not match"))
    end

    # Solve Lz = b
    # Substract lower part from b vector,
    # because we know that L diagonal has only ones
    # We will keep z directly in b vector
    for col in 1:matrix.n-1
      for row in col+1:matrix.col_ranges[col].stop
        b[row] -= matrix[row, col] * b[col]
      end
    end

    # Solve Ux = z
    # Go through rows in reverse order
    # We've already computed z above and saved it in b vector
    xs = b[1:end]
    for row in matrix.n:-1:1
      for col in row+1:matrix.row_ranges[row].stop
        xs[row] -= matrix[row, col] * xs[col]
      end
      xs[row] /= matrix[row, row]
    end

    return xs
  end


  """
      solve_lu_partial_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64}, permutation::Vector{Int64})::Vector{Float64}
  
  Solves the system Ax = b using LU decomposition with partial pivoting.
  The matrix A is modified in the process.

  ## Arguments
  - `matrix`: The matrix A
  - `b`: The vector b
  - `permutation`: The permutation vector

  ## Returns
  - `Vector{Float64}`: The solution vector x
  """
  function solve_lu_partial_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64}, permutation::Vector{Int64})::Vector{Float64}
    if (matrix.n != length(b))
      throw(DimensionMismatch("Matrix and vector dimensions do not match"))
    end

    # Solve Lz = b
    for row in 2:matrix.n
      for col in matrix.row_ranges[permutation[row]].start:row-1
        b[permutation[row]] -= matrix[permutation[row], col] * b[permutation[col]]
      end
    end
    
    # Solve Ux = z
    # Go through rows in reverse order
    # We've already computed z above and saved it in xs vector
    xs = zeros(Float64, matrix.n)
    for row in matrix.n:-1:1
      xs[row] = b[permutation[row]]
      for col in row+1:last_nonzero_column(matrix.n, matrix.l, row + matrix.l)
        xs[row] -= matrix[permutation[row], col] * xs[col]
      end
      xs[row] /= matrix[permutation[row], row]
    end

    return xs
  end


  #=======================#
  # Generate LU and solve #
  #=======================#


  """
      compute_and_solve_lu_no_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}
  
  Computes LU decomposition without pivoting and solves the system Ax = b.

  ## Arguments
  - `matrix`: The matrix A
  - `b`: The vector b

  ## Returns
  - `Vector{Float64}`: The solution vector x
  """
  function compute_and_solve_lu_no_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}
    lu_no_pivoting!(matrix)
    return solve_lu_no_pivoting!(matrix, b)
  end


  """
      compute_and_solve_lu_partial_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}

  Computes LU decomposition with partial pivoting and solves the system Ax = b.

  ## Arguments
  - `matrix`: The matrix A
  - `b`: The vector b

  ## Returns
  - `Vector{Float64}`: The solution vector x
  """
  function compute_and_solve_lu_partial_pivoting!(matrix::BlockSparseMatrix, b::Vector{Float64})::Vector{Float64}
    permutation = lu_partial_pivoting!(matrix)
    return solve_lu_partial_pivoting!(matrix, b, permutation)
  end

end