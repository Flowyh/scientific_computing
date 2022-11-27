#=
  Rozwiązanie zadania 5. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal3l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 19.11.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#
include("iterative_root_approx.jl")
using .IterativeRootApprox

"""
    f(x::Float64)

Implementation of f(x) from task's description.

## Arguments:

- `x` - floating point number

## Returns:

- `exp(x) - 3x`
"""
f(x)  = exp(x) - 3x

# Task precisions
const DELTA = 1e-4
const EPSILON = 1e-4

"""
Main program function.
"""
function main(args::Array{String})
  # Bisekcja x ~ 0.619061...
  bisekcja1 = mbisekcji(f, Float64(0.5), Float64(0.7), DELTA, EPSILON)
  pretty_results_print(bisekcja1, "Metoda bisekcji")
  # Bisekcja x ~ 1.512134...
  bisekcja2 = mbisekcji(f, Float64(1.4), Float64(1.6), DELTA, EPSILON)
  pretty_results_print(bisekcja2, "Metoda bisekcji")

  # Latex
  # println()
  # results_latex_row(bisekcja1)
  # results_latex_row(bisekcja2)
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end