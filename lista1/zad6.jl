#=
  Rozwiązanie zadania 6. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal1l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 21.10.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#

"""
    f(x::Float64)

Implementation of f(x) from task's description.

## Arguments:

- `x` - floating point number

## Returns:

- `sqrt(x^2 + 1) - 1`
"""
f(x::Float64) = sqrt(x^2 + one(Float64)) - one(Float64)

"""
    g(x::Float64)

Implementation of g(x) from task's description.

## Arguments:

- `x` - floating point number

## Returns:

- `x^2 / (sqrt(x^2 + 1) + 1)`
"""
g(x::Float64) = x^2 / (sqrt(x^2 + one(Float64)) + one(Float64))

"""
Main program function.
"""
function main(args::Array{String})
  if length(args) < 1
    println("Usage: julia zad6.jl [k, where range=[8^-1, ... 8^(-k)]]")
    throw("Please provide at least one argument.")
  end

  for i = 1:parse(Int, args[1])
    curr::String = "8^(-$(i))"
    arg::Float64 = Float64(8)^(-i)
    println("x = $curr")
    println("   f($curr) = $(f(arg))")
    println("   g($curr) = $(g(arg))")
    println()
  end

  # println("LaTex table: ")
  # for i = 1:parse(Int, args[1])
  #   arg::Float64 = Float64(8)^(-i)
  #   println("$(i) & \$$(f(arg))\$ & \$$(g(arg))\$ \\\\")
  # end
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end