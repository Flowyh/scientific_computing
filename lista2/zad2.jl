#=
  Rozwiązanie zadania 2. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal2l.pdf
  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 11.11.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743

  @Flowyh (https://github.com/Flowyh)
=#

using Plots
ENV["GKSwstype"] = "100"
using LaTeXStrings

e = MathConstants.e
f(x) = exp(x)*log(1.0 + exp(-x))

function main(args::Array{String})
  pl = plot(
        f, 
        -15.0,
        50.0; 
        title=L"f(x) = e^x \ln(1 + e^{-x})",
        xlims=(-15.0, 50.0),
        ylims=(0.0, 2.0),
        framestyle=:zerolines,
        label="f(x)",
        legend=:topleft,
        legendfontsize=5
      )
  Plots.svg(pl, "zad2.svg")
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end

