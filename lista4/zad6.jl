#=
  Rozwiązanie zadania 6. z listy zadań:
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
  f(x) = abs(x) 
  println("|x|; n=5")
  rysujNnfx(f, -1., 1., 5; f_name=L"|x|", save_path="./plots/zad6/abs_n5.svg")
  println("|x|; n=10")
  rysujNnfx(f, -1., 1., 10; f_name=L"|x|", save_path="./plots/zad6/abs_n10.svg")
  println("|x|; n=15")
  rysujNnfx(f, -1., 1., 15; f_name=L"|x|", save_path="./plots/zad6/abs_n15.svg")
  # println("|x|; n=20")
  # rysujNnfx(f, -1., 1., 20; f_name=L"|x|", save_path="./plots/zad6/abs_n20.svg")
  # println("|x|; n=50")
  # rysujNnfx(f, -1., 1., 50; f_name=L"|x|", save_path="./plots/zad6/abs_n50.svg")

  g(x) = 1 / (1 + x^2)
  println("1/(1+x^2); n=5")
  rysujNnfx(g, -5., 5., 5; f_name=L"\frac{1}{1+x^2}", save_path="./plots/zad6/1_1x2_n5.svg")
  println("1/(1+x^2); n=10")
  rysujNnfx(g, -5., 5., 10; f_name=L"\frac{1}{1+x^2}", save_path="./plots/zad6/1_1x2_n10.svg")
  println("1/(1+x^2); n=15")
  rysujNnfx(g, -5., 5., 15; f_name=L"\frac{1}{1+x^2}", save_path="./plots/zad6/1_1x2_n15.svg")
  # println("1/(1+x^2); n=20")
  # rysujNnfx(g, -5., 5., 20; f_name=L"\frac{1}{1+x^2}", save_path="./plots/zad6/1_1x2_n20.svg")
  # println("1/(1+x^2); n=50")
  # rysujNnfx(g, -5., 5., 50; f_name=L"\frac{1}{1+x^2}", save_path="./plots/zad6/1_1x2_n50.svg")
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end