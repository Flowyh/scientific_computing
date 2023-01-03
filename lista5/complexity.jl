#=
  Program do tworzenia wykresów złożoności obliczeniowej.
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal5l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 29.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#

# Includes

include("blocksys_io.jl")

using LinearAlgebra: norm
using Plots
ENV["GKSwstype"] = "100"

using JSON
using Dates: now

include("matrixgen.jl")
using .matrixgen

# Constants

const MATRICES_FOLDER = "matrices"
const MATRICES_FOLDER_PATH = file_path(MATRICES_FOLDER)

if !isdir(MATRICES_FOLDER_PATH)
  mkdir(MATRICES_FOLDER_PATH)
end


const RESULTS = "results"
const RESULTS_PATH = file_path(RESULTS)

if !isdir(RESULTS_PATH)
  mkdir(RESULTS_PATH)
end 


const PLOTS_FOLDER = "plots"
const PLOTS_FOLDER_PATH = file_path(PLOTS_FOLDER)

if !isdir(PLOTS_FOLDER_PATH)
  mkdir(PLOTS_FOLDER_PATH)
end


"""
    generate_matrices(n_ranges::StepRange, l_values::Vector{Int64}, ck::Float64)

Generate matrices for n in `n_ranges` and l in `l_values` and save them to files
in `MATRICES_FOLDER` folder. The matrices are generated using `blockmat` function
from `matrixgen.jl` module.

# Arguments

- `n_ranges::StepRange`: Range of n values.
- `l_values::Vector{Int64}`: Vector of l values.
- `ck::Float64`: condition number of inside blocks.
"""
function generate_matrices(n_ranges::StepRange, l_values::Vector{Int64}, ck::Float64)
  for n in n_ranges
    for l in l_values
      println("Generating matrix n=$(n) l=$(l) ck=$(ck)...")
      output_path = file_path("$MATRICES_FOLDER/n$(n)l$(l)ck$(ck).txt")
      blockmat(n, l, ck, output_path)

      while true
        all_nonzero = true
        A = read_blocksparsematrix_from_file(output_path)
        for i in 1:n
          if isapprox(A[i, i], 0.)
            all_nonzero = false
            break
          end
        end
        if all_nonzero
          break
        else
          println("Some diagonal elements are zero. Regenerating matrix...")
          blockmat(n, l, ck, output_path)
        end
      end
    end
  end
end


"""
    generate_results()

Generate linear equation solving method results for matrices in `MATRICES_FOLDER`.
"""
function generate_results()
  method_names::Dict{String, Function} = Dict(
    "gauss" => gauss_no_pivoting!,
    "gauss_partial_pivoting" => gauss_partial_pivoting!,
    "lu" => compute_and_solve_lu_no_pivoting!,
    "lu_partial_pivoting" => compute_and_solve_lu_partial_pivoting!
  )

  # memory["l"]["method"]["n"] = Dict("time" => [], "error" => [], 
  #                                    no_getindex = 0, no_setindex = 0)
  memory = Dict()

  for file in readdir(MATRICES_FOLDER_PATH)
    for method_name in ["gauss", "gauss_partial_pivoting", "lu", "lu_partial_pivoting"]
      println("\n\nFile: $(file) Method: $(method_name)")
      input_path = file_path("$MATRICES_FOLDER/$file")
      println("   Reading A from file $(input_path)...")
      A = read_blocksparsematrix_from_file(input_path)
      l = A.l
      n = A.n

      println("   Getting b vector...")
      b = get_b_vector(A)
      method = method_names[method_name]

      println("   Computing x using $(method_name) method...")
      stats = @timed method(A, b)
      time = stats.time
      x = stats.value
      bytes = stats.bytes
      
      println("   Computing error...")
      x_ones = ones(size(x))
      error = norm(x - x_ones) / norm(x_ones)

      if !haskey(memory, l)
        memory[l] = Dict()
      end
      
      if !haskey(memory[l], method_name)
        memory[l][method_name] = Dict()
      end

      println("   Saving results...")
      memory[l][method_name][n] = Dict(
        "time" => time,
        "error" => error,
        "no_getindex" => A.observability.no_getindex,
        "no_setindex" => A.observability.no_setindex,
        "bytes" => bytes
      )
    end
  end

  println("Saving results to file...")
  open(file_path("$RESULTS/$(now()).json"), "w") do io
    JSON.print(io, memory)
  end
end


"""
    values_range(values::Vector, div; roundVals=false)

Return plot ticks range for given vector.
If `roundVals` is true, the values are rounded to Int64.
"""
function values_range(values::Vector; roundVals=false)
  min_val = roundVals ? round(Int64, values[1]) : values[1]
  max_val = roundVals ? round(Int64, values[end]) : values[end]
  len = length(values)
  delta   = roundVals ? round(Int64, (max_val - min_val) / len) : (max_val - min_val) / len
  range = [min_val]
  for i in 1:len-2
    push!(range, range[end] + delta)
  end
  push!(range, max_val)
  return range
end


"""
    prettyplot(title::String, xlabel::String, ylabel::String)::Plot

Return plot with pretty settings.
"""
function prettyplot(title::String, xlabel::String, ylabel::String)
  return plot(
    size=(600, 400),
    title=title,
    xlabel=xlabel,
    ylabel=ylabel,
    formatter=:plain,
    legend=:bottomright,
    legendfontsize=7,
    xrotation=45,
    margin = 3Plots.mm,
    titlefontsize=11,
    titlealign=:center
  )
end


"""
    generate_plots()

Generate plots for results in `RESULTS` folder.
"""
function generate_plots()
  for file in readdir(RESULTS_PATH)
    println("Generating plots for file $(file)...")
    input_path = file_path("$RESULTS/$file")
    results = JSON.parsefile(input_path)

    for l in keys(results)
      p_time = prettyplot(
        "Elapsed time for linear equations solving methods [l=$(l)]",
        "Matrix size (n x n)",
        "Time [s]"
      )
      p_memory = prettyplot(
        "Memory usage for linear equations solving methods [l=$(l)]",
        "Matrix size (n x n)",
        "Memory usage [Mb]"
      )
      p_error = prettyplot(
        "Relative error for linear equations solving methods [l=$(l)]",
        "Matrix size (n x n)",
        "Relative error"
      )
      p_no_getindex = prettyplot(
        "Number of matrix accesses [l=$(l)]",
        "Matrix size (n x n)",
        "Number of accesses"
      )
      p_no_setindex = prettyplot(
        "Number of matrix assignments [l=$(l)]",
        "Matrix size (n x n)",
        "Number of assignments"
      )

      n_range = nothing
      for method in keys(results[l])
        n_values =  parse.(Int64, keys(results[l][method]) |> collect) |> sort
        if isnothing(n_range) 
          n_range = n_values[1]:n_values[2]-n_values[1]:n_values[end]
          xticks!(p_time, n_range)
          xticks!(p_memory, n_range)
          xticks!(p_error, n_range)
          xticks!(p_no_getindex, n_range)
          xticks!(p_no_setindex, n_range)
        end

        time_values = [results[l][method]["$n"]["time"] for n in n_values]
        memory_values = [results[l][method]["$n"]["bytes"] / 1e6 for n in n_values]
        error_values = [results[l][method]["$n"]["error"] for n in n_values]
        no_getindex_values = [results[l][method]["$n"]["no_getindex"] for n in n_values]
        no_setindex_values = [results[l][method]["$n"]["no_setindex"] for n in n_values]

        println("Generating plots for l=$(l) method=$(method)...")
        plot!(p_time, n_values, time_values, label="$method")
        plot!(p_memory, n_values, memory_values, label="$method")
        plot!(p_error, n_values, error_values, label="$method")
        plot!(p_no_getindex, n_values, no_getindex_values, label="$method")
        plot!(p_no_setindex, n_values, no_setindex_values, label="$method")
      end
      savefig(p_time, file_path("$PLOTS_FOLDER/time_l$(l).svg"))
      savefig(p_memory, file_path("$PLOTS_FOLDER/memory_l$(l).svg"))
      savefig(p_error, file_path("$PLOTS_FOLDER/error_l$(l).svg"))
      savefig(p_no_getindex, file_path("$PLOTS_FOLDER/no_getindex_l$(l).svg"))
      savefig(p_no_setindex, file_path("$PLOTS_FOLDER/no_setindex_l$(l).svg"))
    end
  end
end


"""
    usage()

Prints program usage information.
"""
function usage()
  println("Please provide at least 1 argument:")
  println("Usage: julia main.jl mode [n_start] [n_step] [n_end] [l_values] [ck]")
  println("Available modes: --help, matrices, results, plots")
  println("--help prints this message.")
  println("If you pick matrices mode, you have to provide all arguments in square brackets.")
  println("Results will be generated from all files in matrices folder.")
  println("Plots will be generated from all files in results folder.")
end


"""
    main(args::Vector{String})
Main program function.
Reads arguments from command line and calls appropriate functions.
"""
function main(args::Vector{String})
  if length(args) < 1
    usage()
    return
  end

  mode = args[1]

  if (mode == "matrices") && (length(args) < 6)
    usage()
    return
  end

  if mode == "matrices"
    n_ranges = StepRange(parse(Int, args[2]), parse(Int, args[3]), parse(Int, args[4]))
    l_values = parse.(Int, split(args[5], ","))
    ck = parse(Float64, args[6])
    generate_matrices(n_ranges, l_values, ck)
  elseif mode == "results"
    generate_results()
  elseif mode == "plots"
    generate_plots()
  elseif mode == "--help"
    usage()
  else
    usage()
  end
end


# Equivalent to pythonic if __name__ == "__main__"
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end