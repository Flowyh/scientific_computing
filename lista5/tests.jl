#=
  Główny program testujący zaimplementowane metody rozwiązywania układów równań liniowych.
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal5l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 29.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#


include("./blocksys_io.jl")
using Test

include("./matrixgen.jl")
using .matrixgen: blockmat

using Random: rand


const DATA_PATH = "./dane"


"""
    main(args::Array{String})
Test implemented blocksys methods on matrices from ./dane folder
and randomly generated matrices from matrixgen.jl.
"""
function main(args::Array{String})
  method_names::Dict{String, Function} = Dict(
    "gauss" => gauss_no_pivoting!,
    "gauss_partial_pivoting" => gauss_partial_pivoting!,
    "lu" => compute_and_solve_lu_no_pivoting!,
    "lu_partial_pivoting" => compute_and_solve_lu_partial_pivoting!
  )

  # For each folder in "./dane" run all methods
  for dataset in readdir(DATA_PATH)
    @testset "$DATA_PATH/$dataset" begin
      for method_name in keys(method_names)
        println("n = $dataset, method = $method_name")
        matrix_path = file_path("$DATA_PATH/$dataset/A.txt")
        b_vector_path = file_path("$DATA_PATH/$dataset/b.txt")
        A = read_blocksparsematrix_from_file(matrix_path)
        b = read_b_vector_from_file(b_vector_path)
        method = method_names[method_name]
        x = method(deepcopy(A), deepcopy(b))

        @test isapprox(A * x, b)
      end
    end
  end

  # Random tests using blockmat from matrixgen.jl and random b vector
  @testset "random matrices, random b" begin
    for ck in [10., 100., 1000.]
      for n in [100, 1000, 10000]
        for l in [4, 5, 10, 25]
          for method_name in keys(method_names)
              println("Ck = $ck, n = $n, l = $l, method = $method_name")
              blockmat(n, l, ck, "temp.txt")
              matrix_path = file_path("temp.txt")
              A = read_blocksparsematrix_from_file(matrix_path)
              b = rand(Float64, n)
              method = method_names[method_name]
              x = method(deepcopy(A), deepcopy(b))

              @test isapprox(A * x, b)
          end
        end
      end
    end
  end

  rm("temp.txt")
end


# Equivalent to pythonic if __name__ == "__main__"
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end