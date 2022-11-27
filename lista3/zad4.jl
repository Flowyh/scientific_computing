#=
  Rozwiązanie zadania 4. z listy zadań:
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

- `sin(x) - (1 / 2 * x)^2`
"""
f(x::Float64)  = sin(x) - (1 / 2 * x)^2

"""
    df(x::Float64)

`f(x)` derivative.

## Arguments:

- `x` - floating point number

## Returns:

- `cos(x) - (x / 2)`
"""
df(x::Float64) = cos(x) - (x / 2)

# Task precisions
const DELTA = 1/2 * 1e-5
const EPSILON = 1/2 * 1e-5

"""
Main program function.
"""
function main(args::Array{String})
  # Bisekcja
  bisekcja = mbisekcji(f, Float64(1.5), Float64(2), DELTA, EPSILON)
  pretty_results_print(bisekcja, "Metoda bisekcji")
  # Newton
  newton = mstycznych(f, df, Float64(1.5), DELTA, EPSILON, 1000)
  pretty_results_print(newton, "Metoda stycznych")
  # Sieczne
  sieczne = msiecznych(f, Float64(1), Float64(2), DELTA, EPSILON, 1000)
  pretty_results_print(sieczne, "Metoda siecznych")

  # Latex
  # println()
  # results_latex_row(bisekcja)
  # results_latex_row(newton)
  # results_latex_row(sieczne)
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end