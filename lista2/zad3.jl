#=
  Rozwiązanie zadania 3. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal2l.pdf
  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 11.11.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743

  @Flowyh (https://github.com/Flowyh)
=#

using LinearAlgebra


"""
    matcond(n::UInt64, c::Float64)

## Author: Pawel Zielinski (https://cs.pwr.edu.pl/zielinski/)

Function generates a random square matrix A of size n with
a given condition number c.

## Arguments:

- `n::UInt64` - size of matrix A, n > 1
- `c::Float64` - condition of matrix A, c>= 1.0

# Examples:
```julia-repl
julia> matcond(10, 100.0)
3×3 Matrix{Float64}:
  26.2301   -58.3213   14.8724
 -31.96      27.6672   24.3258
  -5.27693   60.6611  -46.4155
"""
function matcond(n::UInt64, c::Float64)
  if n < 2
    error("size n should be > 1")
  end
  if c< 1.0
    error("condition number  c of a matrix  should be >= 1.0")
  end
  (U,S,V)=svd(rand(n,n))
  return U*diagm(0 =>[LinRange(1.0,c,n);])*V'
end


"""
    hilb(n::UInt64)

Author: Pawel Zielinski (https://cs.pwr.edu.pl/zielinski/)

Function generates the Hilbert matrix A of size n:
A(i, j) = 1 / (i + j - 1).

## Arguments:

- `n::UInt64` - size of matrix A, n>=1

# Examples:
```julia-repl
julia> hilb(3)
3×3 Matrix{Float64}:
  1.0       0.5       0.333333
  0.5       0.333333  0.25
  0.333333  0.25      0.25
"""
function hilb(n::UInt64, _...)
  if n < 1
    error("size n should be >= 1")
  end
  return [1 / (i + j - 1) for i in 1:n, j in 1:n]
end

"""
Gauss elimination method:
x = A \\ b
"""
gauss_method(matrix, b) = matrix \ b

"""
Matrix inverse method:
x = A^(-1) * b
"""
inverse_method(matrix, b) = inv(matrix) * b

"""
    matrix_test(matrix_gen::Function, args::Tuple{UInt64, UInt64})

Performs several linear equations solving tests on a matrix `A`
generated by `matrix_gen` function, such that `A` * `x` = b, where
`x`` is a vector of ones.

## Arguments:

- `matrix_gen::Function` - matrix generation method
- `args::Tuple{UInt64, UInt64}` - a pair of arguments needed for `matrix_gen`
                                  function: `size` and `cond`

## Returns:

- `A`'s size, rank, condition number, gauss method error, inverse method error
"""
function matrix_test(
  matrix_gen::Function,
  args::Tuple{UInt64, Float64}
)
  (size::UInt64, con::Float64) = args
  matrix = matrix_gen(size, con)

  x = ones(size)
  b = matrix * x

  matrix_rank = rank(matrix)
  matrix_cond = cond(matrix)
  x_norm = norm(x)

  matrix_gauss_method = gauss_method(matrix, b)
  matrix_inverse_method = inverse_method(matrix, b)

  matrix_gauss_error = norm(matrix_gauss_method - x) / x_norm
  matrix_inverse_error = norm(matrix_inverse_method - x) / x_norm

  return (size, matrix_rank, matrix_cond, matrix_gauss_error, matrix_inverse_error)
end


"""
    typed_globals()

This function acts as a placeholder for global variables needed for this task.
  In Julia 1.8> this function is obsolete, because global variable typing was
  introduced in version 1.8.
  Nevertheless, to maintain backwards-compatibility I've opted to keep those
  variables as I would do in previous versions.

## Returns:
- Global typed variables.
"""
function typed_globals()
  random_sizes::Vector{UInt64} = [5, 10, 20]
  conds::Vector{Float64} = [1.0, 10.0, 10^3, 10^7, 10^12, 10^16]
  hilbert_sizes::Vector{UInt64} = [i for i in 1:2:40]

  return (random_sizes, conds, hilbert_sizes)
end


"""
Print formatted latex table row.
"""
latex_table_row((s, r, c, ge, ie)) = println("\$$s\$ & \$$r\$ & \$$c\$ & \$$ge\$ & \$$ie\$ \\\\")


"""
Main program function.
"""
function main(args::Vector{String})
  (random_sizes, conds, hilbert_sizes) = typed_globals()

  println("Hilbert matrix test")
  for size in hilbert_sizes
    res = matrix_test(hilb, (size, Float64(0)))
    latex_table_row(res)
  end

  println()

  println("Random matrix test")
  for size in random_sizes, cond in conds
    res = matrix_test(matcond, (size, cond))
    latex_table_row(res)
  end

  println("")
end


# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end