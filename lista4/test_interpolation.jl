#=
  Testy do funkcji z zadania 1. 2. i 3. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal4l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 08.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#

include("interpolation.jl")
using .Interpolation
using Test

"""
Test interpolation algorithms.
"""
function main(args::Array{String})
  @testset "Ilorazy różnicowe" begin
    xs::FloatVec = [3, 1, 5, 6]
    fxs::FloatVec = [1, -3, 2, 4]
    expected::FloatVec = [1, 2, -3/8, 7/40]

    # Przykład z wykładu
    @test isapprox(ilorazyRoznicowe(xs, fxs), expected)

    xs2::FloatVec = [1, 5, 6, 7]
    fxs2::FloatVec = [-5, 2, 10, -6]
    expected2::FloatVec = [-5, 7/4, 5/4, -53/24]

    @test isapprox(ilorazyRoznicowe(xs2, fxs2), expected2)
  end

  @testset "Wartość Newton" begin
    xs::FloatVec = [3, 1, 5, 6]
    fxs::FloatVec = [1, -3, 2, 4]
    expected::FloatVec = [1, 2, -3/8, 7/40]
    ilorazy::FloatVec = ilorazyRoznicowe(xs, fxs)
    
    @test isapprox(warNewton(ilorazy, xs, 3.5), 111.4375)
    @test isapprox(warNewton(ilorazy, xs, 0.), 16.5)

    xs2::FloatVec = [1, 5, 6, 7]
    fxs2::FloatVec = [-5, 2, 10, -6]
    expected2::FloatVec = [-5, 7/4, 5/4, -53/24]
    ilorazy2::FloatVec = ilorazyRoznicowe(xs2, fxs2)

    @test isapprox(warNewton(ilorazy2, xs2, 3.5), 367.03125)
    @test isapprox(warNewton(ilorazy2, xs2, 0.), 50.0625)
  end

  @testset "Postać naturalna Newtona" begin
    xs::FloatVec = [3, 1, 5, 6]
    fxs::FloatVec = [1, -3, 2, 4]
    ilorazy::FloatVec = ilorazyRoznicowe(xs, fxs)
    expected::FloatVec = [-8.75, 7.525, -1.95, 0.175]

    @test isapprox(naturalna(xs, ilorazy), expected)

    xs2::FloatVec = [1, 5, 6, 7]
    fxs2::FloatVec = [-5, 2, 10, -6]
    ilorazy2::FloatVec = ilorazyRoznicowe(xs2, fxs2)
    expected2::FloatVec = [65.75, -96.291666, 27.75, -2.208333]

    @test isapprox(naturalna(xs2, ilorazy2), expected2)
  end

  # @testset "Wykresy" begin
  #   rysujNnfx(x -> exp(x), 0., 1., 5; f_name="e^x", save_path="e^x.svg")
  # end
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end