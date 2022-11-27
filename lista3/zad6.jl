#=
  Rozwiązanie zadania 6. z listy zadań:
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
    f1(x::Float64)

Implementation of f1(x) from task's description.

## Arguments:

- `x` - floating point number

## Returns:

- `exp(1 - x) - 1`
"""
f1(x)  = exp(1 - x) - 1

"""
    df1(x::Float64)

`f1(x)` derivative.

## Arguments:

- `x` - floating point number

## Returns:

- `-exp(1 - x)`
"""
df1(x) = -exp(1 - x)

"""
    f2(x::Float64)

Implementation of f2(x) from task's description.

## Arguments:

- `x` - floating point number

## Returns:

- `x * exp(-x)`
"""
f2(x)  = x * exp(-x)

"""
    df2(x::Float64)

`f2(x)` derivative.

## Arguments:

- `x` - floating point number

## Returns:

- `-exp(-x) * (x - 1)`
"""
df2(x) = -exp(-x) * (x - 1)

# Task precisions
const DELTA = 1e-5
const EPSILON = 1e-5

"""
f1(x) tests for each epproximation method.
"""
function f1_test()
  println("================exp(1 - x) - 1==================")
  # Bisekcja
  bisekcja = mbisekcji(f1, Float64(0.2), Float64(2), DELTA, EPSILON)
  pretty_results_print(bisekcja, "Metoda bisekcji")
  # Newton
  newton = mstycznych(f1, df1, Float64(0.9), DELTA, EPSILON, 1000)
  pretty_results_print(newton, "Metoda stycznych")
  # Sieczne
  sieczne = msiecznych(f1, Float64(0.2), Float64(2), DELTA, EPSILON, 1000)
  pretty_results_print(sieczne, "Metoda siecznych")
  println("================================================")
  println()
  # results_latex_row(bisekcja)
  # results_latex_row(newton)
  # results_latex_row(sieczne)
  # println("================================================")
end

"""
f2(x) tests for each epproximation method.
"""
function f2_test()
  println("=================x * exp(-x)====================")
  # Bisekcja
  bisekcja = mbisekcji(f2, Float64(-1), Float64(0.5), DELTA, EPSILON)
  pretty_results_print(bisekcja, "Metoda bisekcji")
  # Newton
  newton = mstycznych(f2, df2, Float64(0.9), DELTA, EPSILON, 1000)
  pretty_results_print(newton, "Metoda stycznych")
  # Sieczne
  sieczne = msiecznych(f2, Float64(-1), Float64(0.5), DELTA, EPSILON, 1000)
  pretty_results_print(sieczne, "Metoda siecznych")
  println("================================================")
  println()
  # results_latex_row(bisekcja)
  # results_latex_row(newton)
  # results_latex_row(sieczne)
  # println("================================================")
end

"""
Print Newton method tests into the console.
"""
function newton_tests()
  # Testowanie Newtona dla f1 i x > 1
  println("======Testy metody Newtona dla f1 i x0 > 1======")
  for i = 2:20
    newton = mstycznych(f1, df1, Float64(i), DELTA, EPSILON, 1000)
    pretty_results_print(newton, "Metoda stycznych")
  end
  println("================================================")
  println()
  println("======Testy metody Newtona dla f2 i x0 > 1======")
  # Testowanie Newtona dla f2 i x > 1
  for i = 2:20
    newton = mstycznych(f2, df1, Float64(i), DELTA, EPSILON, 1000)
    pretty_results_print(newton, "Metoda stycznych")
  end
  println("================================================")
  println()
end

"""
Prints Netwon method's test as latex table.
"""
function newton_latex()
  # Testowanie Newtona dla f1 i x > 1
  println("TESTY DLA f1")
  for i = 2:20
    newton = mstycznych(f1, df1, Float64(i), DELTA, EPSILON, 1000)
    print("\$$i\$ & ")
    results_latex_row(newton)
  end
  println()
  println("TESTY DLA f2")
  # Testowanie Newtona dla f2 i x > 1
  for i = 2:20
    newton = mstycznych(f2, df1, Float64(i), DELTA, EPSILON, 1000)
    print("\$$i\$ & ")
    results_latex_row(newton)
  end
end

"""
Main program function.
"""
function main(args::Array{String})
  f1_test()
  f2_test()
  newton_tests()
  # newton_tests()
  # newton_latex()
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end