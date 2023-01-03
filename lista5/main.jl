#=
  Główny program uruchamiający zaimplementowane metody rozwiązywania układów równań liniowych.
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal5l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 29.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#


include("./blocksys_io.jl")

using LinearAlgebra: norm

# Global flag to enable/disable benchmarking
const BENCHMARK = false

if BENCHMARK
  using BenchmarkTools: @benchmark, mean, DEFAULT_PARAMETERS
  println("Benchmarking enabled.")
else
  println("Benchmarking disabled.")
end


"""
    usage()
  
Print program usage info.
"""
function usage()
  println("Please provide at least 3 arguments:")
  println("Usage: julia main.jl solving_method matrix_path output_path [b_vector_path]")
  println("Available solving_method values: gauss, gauss_partial_pivoting, lu, lu_partial_pivoting")
end


"""
    main(args::Array{String})

Main function of the program. It parses command line arguments and runs
linear equations solving methods on matrices from files.
"""
function main(args::Array{String})
  if length(args) < 3
    usage()
    return
  end

  solving_method = args[1]
  matrix_path = args[2]
  output_path = args[3]
  b_vector_path = nothing
  b_read_from_file = false

  # Check if b vector was provided as a file
  if length(args) >= 4
    println("B vector was provided as a file.")
    b_vector_path = args[4]
    b_read_from_file = true
  end

  println("Reading matrix from file: $matrix_path. . .")
  A = read_blocksparsematrix_from_file(matrix_path)

  println("Matrix size: $(A.n)x$(A.n)")
  println("Block size: $(A.l)x$(A.l)")

  if !isnothing(b_vector_path)
    println("Reading b vector from file: $b_vector_path. . .")
    b = read_b_vector_from_file(b_vector_path)
  else
    println("Generating b vector. . .")
    b = get_b_vector(A)
  end

  method = nothing
  error = nothing


  if solving_method == "gauss"
    println("Picked method: Gauss with no pivoting")
    method = gauss_no_pivoting!
  elseif solving_method == "gauss_partial_pivoting"
    println("Picked method: Gauss with partial pivoting")
    method = gauss_partial_pivoting!
  elseif solving_method == "lu"
    println("Picked method: LU decomposition with no pivoting")
    method = compute_and_solve_lu_no_pivoting!
  elseif solving_method == "lu_partial_pivoting"
    println("Picked method: LU decomposition with partial pivoting")
    method = compute_and_solve_lu_partial_pivoting!
  else
    usage()
    return
  end

  println("Solving. . .")
  x = method(A, b)
  println("Solved!")

  println("Computing error. . .")
  x_ones = ones(size(x))
  error = norm(x - x_ones) / norm(x_ones)

  println("Writing solution to file: $output_path. . .")
  if b_read_from_file
    write_x_to_file(output_path, x, nothing)
  else
    write_x_to_file(output_path, x, error)
  end
  
  println()

  println("Results:")
  println("Error: $error")
  println("$(A.observability)")

  # Benchmarking
  if BENCHMARK
    DEFAULT_PARAMETERS.samples = 1000
    DEFAULT_PARAMETERS.seconds = 60
    println("Benchmarking...")
    bench = @benchmark $method($A, $b)

    mean_time = mean(bench).time
    println("Mean time: $(mean_time) ns")

    println()
    io = IOBuffer()
    show(io, "text/plain", bench)
    println(String(take!(io)))
  end
end


# Equivalent to pythonic if __name__ == "__main__"
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end