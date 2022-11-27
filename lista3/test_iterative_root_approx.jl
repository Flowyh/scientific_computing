#=
  Testy do funkcji z zadania 1. 2. i 3. z listy zadań:
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
using Test

"""
Test iterative root approximation algorithms.
"""
function main(args::Array{String})
  @testset "Metoda bisekcji" begin
    # Funkcja nie zmienia znaku pomiędzy -1 i 1
    @test mbisekcji(x -> x^2, -1.0, 1.0, 1e-10, 1e-10) == IRAR_ERROR_CODE_ONE
    # Funkcja bardzo szybko zbiegnie do pierwiastka (1)
    @test mbisekcji(x -> x^2 - 1, 0.0, 4.0, 1e-10, 1e-10) == IRAResults(1.0, 0.0, 2, 0)
  end

  @testset "Metoda stycznych" begin
    # Pochodna bliska zeru
    @test mstycznych(x -> -x^4 + 8x^2 + 4, x -> -4x^3 + 16x, 0.0, 1e-10, 1e-10, 1) == IRAR_ERROR_CODE_TWO
    # Za mało iteracji
    @test mstycznych(x -> -x^3 + 8x + 4, x -> -3x^3 + 8, 0.0, 1e-10, 1e-10, 1) == IRAR_ERROR_CODE_ONE
    # Dobre dane
    @test mstycznych(x -> -x^3 + 8x + 4, x -> -3x^3 + 8, 0.0, 1e-10, 1e-10, 20) == IRAResults(-0.5173040449987795, 6.856071266270192e-11, 12, 0x00)
  end

  @testset "Metoda siecznych" begin
    # Za mało iteracji
    @test msiecznych(x -> -x^3 + 8x + 4, -1.0, 1.0, 1e-10, 1e-10, 1) == IRAR_ERROR_CODE_ONE
    # Dobre dane
    @test msiecznych(x -> -x^3 + 8x + 4, -1.0, 1.0, 1e-10, 1e-10, 20) == IRAResults(-0.517304045003447, 3.496802847280378e-11, 5, 0x00)
  end
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end