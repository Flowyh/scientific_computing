#=
  Pomocnicze funkcje do wczytywania macierzy i wektora b z pliku oraz zapisywania 
  wektora wynikowego do pliku.
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal5l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 29.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#


include("./blocksys.jl")
using .blocksys

# Helper function to get path relative to current file
file_path(path::String) = joinpath(@__DIR__, path)

"""
    read_blocksparsematrix_from_file(path::String)::BlockSparseMatrix

Reads a matrix from a file in the following format:

n l
row_1 column_1 value_1
row_2 column_2 value_2
...

where n is the number of rows and columns of current matrix, l is the block size and
row_i, column_i, value_i are the row, column and value of a non-zero i-th element of the matrix.

## Arguments
- `path::String`: path to the file

## Returns
- `BlockSparseMatrix`: matrix read from the file
"""
function read_blocksparsematrix_from_file(path::String)::BlockSparseMatrix
  open(file_path(path), "r") do file
    n_l = split(readline(file), " ")
    (n, l) = parse.(Int64, n_l)

    values::Vector{BlockSparseMatrixValue} = []
    
    while !eof(file)
      line = readline(file)
      line = split(line, " ")
      row = parse(Int64, line[1])
      column = parse(Int64, line[2])
      val = parse(Float64, line[3])
      push!(values, (row, column, val))
    end

    return BlockSparseMatrix(n, l, values)
  end
end


"""
    read_b_vector_from_file(path::String)::Vector{Float64}

Reads a vector from a file in the following format:

n
value_1
value_2
...

where n is the number of elements of current vector and value_i is the value of i-th vector element.

## Arguments
- `path::String`: path to the file

## Returns
- `Vector{Float64}`: vector read from the file
"""
function read_b_vector_from_file(path::String)::Vector{Float64}
  open(file_path(path), "r") do file
    n = parse(Int64, readline(file))
    values::Vector{Float64} = []

    while !eof(file)
      push!(values, parse.(Float64, readline(file)))
    end

    return values
  end
end


"""
    write_x_to_file(path::String, xs::Vector{Float64}, error::Union{Nothing, Float64})
  
Writes a vector to a file in the following format:

error
value_1
value_2
...

where error is the error of the solution and value_i is the value of i-th vector element.

## Arguments
- `path::String`: path to the file
- `xs::Vector{Float64}`: vector to be written to the file
- `error::Union{Nothing, Float64}`: error of the solution
"""
function write_x_to_file(path::String, xs::Vector{Float64}, error::Union{Nothing, Float64})
  open(file_path(path), "w") do file
    if !isnothing(error)
      write(file, "$error\n")
    end
    for x in xs
      write(file, "$x\n")
    end
  end
end