#=
  Program drukujący tabelki do sprawozdania z listy 5.
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal5l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 29.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#


include("./blocksys_io.jl")

const DATA_PATH = "./dane"

"""
    main(args::Array{String})

Main function of the program. Prints latex tables with results of
linear equations solving methods on matrices from files in "./dane" folder.
"""
function main(args::Array{String})
  method_names::Dict{String, Function} = Dict(
    "gauss" => gauss_no_pivoting!,
    "gauss_partial_pivoting" => gauss_partial_pivoting!,
    "lu" => compute_and_solve_lu_no_pivoting!,
    "lu_partial_pivoting" => compute_and_solve_lu_partial_pivoting!
  )

  memory = Dict()

  # For each folder in "./dane" run all methods
  for dataset in parse.(Int64, readdir("./dane")) |> sort
    println("Dataset: $dataset")
    memory[dataset] = Dict()
    for method_name in ["gauss", "gauss_partial_pivoting", "lu", "lu_partial_pivoting"]
      println("Method: $method_name")
      memory[dataset][method_name] = Dict(
        "error" => 0.,
        "accesses" => 0.,
        "sets" => 0.
      )
      matrix_path = file_path("$DATA_PATH/$dataset/A.txt")
      b_vector_path = file_path("$DATA_PATH/$dataset/b.txt")
      A = read_blocksparsematrix_from_file(matrix_path)
      b = read_b_vector_from_file(b_vector_path)
      method! = method_names[method_name]
      x = method!(A, b)
      x_ones = ones(size(x))
      error = norm(x - x_ones) / norm(x_ones)
      memory[dataset][method_name]["error"] = error
      memory[dataset][method_name]["accesses"] = A.observability.no_getindex
      memory[dataset][method_name]["sets"] = A.observability.no_setindex
    end
  end

  # Error table

  println("ERROR TABLE\n\n")

  for dataset in parse.(Int64, readdir("./dane")) |> sort
    print("\$$dataset\$ ")
    for method_name in ["gauss", "gauss_partial_pivoting", "lu", "lu_partial_pivoting"]
      error = memory[dataset][method_name]["error"]
      print("& \$$error\$ ")
    end
    println("\\\\")
  end

  # Accesses table

  println("\n\nACCESSES TABLE\n\n")

  for dataset in parse.(Int64, readdir("./dane")) |> sort
    print("\$$dataset\$ ")
    for method_name in ["gauss", "gauss_partial_pivoting", "lu", "lu_partial_pivoting"]
      accesses = memory[dataset][method_name]["accesses"]
      print("& \$$accesses\$ ")
    end
    println("\\\\")
  end

  # Sets table

  println("\n\nSETS TABLE\n\n")

  for dataset in parse.(Int64, readdir("./dane")) |> sort
    print("\$$dataset\$ ")
    for method_name in ["gauss", "gauss_partial_pivoting", "lu", "lu_partial_pivoting"]
      sets = memory[dataset][method_name]["sets"]
      print("& \$$sets\$ ")
    end
    println("\\\\")
  end
end


# Equivalent to pythonic if __name__ == "__main__"
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end