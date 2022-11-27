#=
  Rozwiązanie zadania 1. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal2l.pdf
  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 11.11.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743

  @Flowyh (https://github.com/Flowyh)
=#

# Alias of acceptable Float types for this task
Floats = Union{Float32, Float64}


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
  x32::Vector{Float32} = map(Float32, [2.718281828, -3.141592654, 1.414213562, 0.5772156649, 0.3010299957])
  y32::Vector{Float32} = map(Float32, [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049])

  x64::Vector{Float64} = map(Float64, [2.718281828, -3.141592654, 1.414213562, 0.5772156649, 0.3010299957])
  y64::Vector{Float64} = map(Float64, [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049])

  modified_x32::Vector{Float32} = map(Float32, [2.718281828, -3.141592654, 1.414213562, 0.577215664, 0.301029995])
  modified_y32::Vector{Float32} = map(Float32, [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049])

  modified_x64::Vector{Float64} = map(Float64, [2.718281828, -3.141592654, 1.414213562, 0.577215664, 0.301029995])
  modified_y64::Vector{Float64} = map(Float64, [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049])

  return (x32, y32, x64, y64, modified_x32, modified_y32, modified_x64, modified_y64)
end


"""
    sum_forward(x::Vector{Float64}, y::Vector{Float64})
    
Calculates scalar products of two Float32 or Float64 vectors (with same lengths)
using "summing forward" strategy.
It basically sums partial products from the first elements of both vectors
to the last.
## Arguments:
- `x` - vector of floating point numbers
- `y` - vector of floating point numbers
## Returns:
- Scalar product of x and y
"""
function sum_forward(x::Vector{T}, y::Vector{T})::T where T <: Floats
  if length(x) != length(y)
    throw("Vector length mismatch.")
  end

  S::T = zero(T)

  for i = 1:length(x)
    S = S + x[i] * y[i]
  end

  return S
end


"""
    sum_backwards(x::Vector{Float64}, y::Vector{Float64})

Calculates scalar products of two Float32 or Float64 vectors (with same lengths)
using "summing backwards" strategy.
It basically sums partial products from the lest elements of both vectors
to the first.
## Arguments:
- `x` - vector of floating point numbers
- `y` - vector of floating point numbers
## Returns:
- Scalar product of x and y
"""
function sum_backwards(x::Vector{T}, y::Vector{T})::T where T <: Floats
  if length(x) != length(y)
    throw("Vector length mismatch.")
  end

  S::T = zero(T)

  for i = length(x):-1:1
    S = S + x[i] * y[i]
  end

  return S
end


"""
    sum_largest_to_smallest(x::Vector{Float64}, y::Vector{Float64})

Calculates scalar products of two Float32 or Float64 vectors (with same lengths)
using "summing largest to smallest" strategy.
Positive partial products are summed from the largest to the smallest.
Negative partial products are summed from the smallest to the largest.
## Arguments:
- `x` - vector of floating point numbers
- `y` - vector of floating point numbers
## Returns:
- Scalar product of x and y
"""
function sum_largest_to_smallest(x::Vector{T}, y::Vector{T})::T where T <: Floats
  if length(x) != length(y)
    throw("Vector length mismatch.")
  end

  muls = map((x, y) -> x * y, x, y)

  # Thank you prof. Cichon: https://cs.pwr.edu.pl/cichon/2022_23_a/FuncP.php
  positive = filter(x -> x > zero(T), muls) |> x -> sort(x, rev=true)
  negative = filter(x -> x <= zero(T), muls) |> x -> sort(x, rev=false)
  return foldl(+, positive) + foldl(+, negative)
end


"""
    sum_smallest_to_largest(x::Vector{Float64}, y::Vector{Float64})

Calculates scalar products of two Float32 or Float64 vectors (with same lengths)
using "summing smallest to largest" strategy.
Positive partial products are summed from the smallest to the largest.
Negative partial products are summed from the largest to the smallest.
## Arguments:
- `x` - vector of floating point numbers
- `y` - vector of floating point numbers
## Returns:
- Scalar product of x and y
"""
function sum_smallest_to_largest(x::Vector{T}, y::Vector{T})::T where T <: Floats
  if length(x) != length(y)
    throw("Vector length mismatch.")
  end

  muls = map((x, y) -> x * y, x, y)

  # Thank you prof. Cichon: https://cs.pwr.edu.pl/cichon/2022_23_a/FuncP.php
  positive = filter(x -> x > zero(T), muls) |> x -> sort(x, rev=false)
  negative = filter(x -> x <= zero(T), muls) |> x -> sort(x, rev=true)
  return foldl(+, positive) + foldl(+, negative)
end


"""
Main program function.
"""
function main(args::Array{String})
  (x32, y32, x64, y64, mx32, my32, mx64, my64) = typed_globals()

  for func in [sum_forward, sum_backwards, sum_largest_to_smallest, sum_smallest_to_largest]
    func_name::String = String(Symbol(func))
    println(uppercasefirst(replace(func_name, "_" => " ")))
    f32 = func(x32, y32)
    f64 = func(x64, y64)
    mf32 = func(mx32, my32)
    mf64 = func(mx64, my64)
    println("   Float32 (previous): $f32")
    println("   Float32 (modified): $mf32")
    println("   Change: $(f32 - mf32)")
    println("   Float64 (previous): $f64")
    println("   Float64 (modified): $mf64")
    println("   Change: $(f64 - mf64)")
    println()
  end
end


"""
Prints formatted LaTex table for this task.
"""
function latex_table()
  (x32, y32, x64, y64, mx32, my32, mx64, my64) = typed_globals()

  for data in [
    (x32, y32, mx32, my32),
    (x64, y64, mx64, my64)
  ]
    for func in [sum_forward, sum_backwards, sum_largest_to_smallest, sum_smallest_to_largest]
      func_name::String = String(Symbol(func))
      (x, y, mx, my) = data
      res = func(x, y)
      modified_res = func(mx, my)
      println("$(func_name) & \$$res\$ & \$$modified_res\$ & \$$(res - modified_res)\$ \\\\")
    end
    println()
  end

end


# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
  # latex_table()
end