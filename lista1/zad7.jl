#=
  Rozwiązanie zadania 7. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal1l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 21.10.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#

"""
    derivative_approx(f::Function, x0::Float64, h::Float64)

Implementation of derivative approximation formula ((f(x0 + h) - f(x0)) / h).

## Arguments:

- `f` - function f(x)
- `x0` - derivative point
- `h` - small change of x

## Returns:

- Approximation of f'(x0)
"""
derivative_approx(f::Function, x0::Float64, h::Float64) = (f(x0 + h) - f(x0)) / h

"""
    f(x::Float64)

Implementation of f(x) from task's description.

## Arguments:

- `x` - floating point number

## Returns:

- `sin(x) + cos(3x)`
"""
f(x::Float64) = sin(x) + cos(3x)

"""
    f_deriv(x::Float64)

True derivative of f(x) from task's description.

## Arguments:

- `x` - floating point number

## Returns:

- `cos(x) + 3sin(3x)`
"""
f_deriv(x::Float64) = cos(x) - 3sin(3x)

"""
Main program function.
"""
function main(args::Vector{String})
  hs::Array{Float64} = [Float64(2)^(-n) for n in 0:54]
  x0 = one(Float64)

  for (i, h) in enumerate(hs)
    println("H (2^(-$(i - 1))) = $(h)")
    println("   x0 + h = $(x0 + h)")
    approx = derivative_approx(f, x0, h)
    println("   Derivative approximation = $(approx)")
    exact = f_deriv(x0)
    println("   Exact derivative = $(exact)")
    println("   Error = $(abs(exact - approx))")
  end

  # println("LaTex table: ")
  # for (i, h) in enumerate(hs)
  #   approx = derivative_approx(f, x0, h)
  #   exact = f_deriv(x0)
  #   println("\$2^{-$(i - 1)}\$ & \$$(x0 + h)\$ & \$$(approx)\$ & \$$(abs(exact - approx))\$ \\\\")
  # end  
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end