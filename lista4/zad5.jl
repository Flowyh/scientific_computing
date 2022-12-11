#=
  Rozwiązanie zadania 5. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal4l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 09.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#

include("interpolation.jl")
using .Interpolation
using LaTeXStrings

"""
Main program function.
"""
function main(args::Array{String})
  f(x) = exp(x)
  println("e^x; n=5")
  rysujNnfx(f, 0., 1., 5; f_name=L"e^x", save_path="./plots/zad5/exp_n5.svg")
  println("e^x; n=10")
  rysujNnfx(f, 0., 1., 10; f_name=L"e^x", save_path="./plots/zad5/exp_n10.svg")
  println("e^x; n=15")
  rysujNnfx(f, 0., 1., 15; f_name=L"e^x", save_path="./plots/zad5/exp_n15.svg")

  g(x) = x^2 * sin(x)
  println("x^2sin(x); n=5")
  rysujNnfx(g, -1., 1., 5; f_name=L"x^2 \sin(x)", save_path="./plots/zad5/x2sinx_n5.svg")
  println("x^2sin(x); n=10")
  rysujNnfx(g, -1., 1., 10; f_name=L"x^2 \sin(x)", save_path="./plots/zad5/x2sinx_n10.svg")
  println("x^2sin(x); n=15")
  rysujNnfx(g, -1., 1., 15; f_name=L"x^2 \sin(x)", save_path="./plots/zad5/x2sinx_n15.svg")
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end