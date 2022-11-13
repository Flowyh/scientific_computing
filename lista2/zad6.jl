#=
  Rozwiązanie zadania 6. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal2l.pdf
  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 11.11.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743

  @Flowyh (https://github.com/Flowyh)
=#

"""
    f(x0::Float64, c::Float64, iterations::Int)

Implementation of the recursive formula described in this task.
"""
function f(x0::Float64, c::Float64, iterations::Int)::Vector{Float64}
  xs::Vector{Float64} = [x0]
  for i::Int in 1:iterations
    push!(xs, xs[i]^2 + c)
  end
  return xs
end


"""
    typed_globals()

This function acts as a placeholder for global variables needed for this task.
In Julia 1.8> this function is obsolete, because global variable typing was
introduced in version 1.8.
Nevertheless, to maintain backwards-compatibility I've opted to keep those
variables as I would do in previous versions.

## Returns:
- Global typed variables.
"""
function typed_globals()
  cs::Vector{Float64} = [-2, -2, -2, -1, -1, -1, -1]
  x0s::Vector{Float64} = [1, 2, 1.99999999999999, 1, -1, 0.75, 0.25]
  iterations::Int = 400
  return (cs, x0s, iterations)
end


"""
Main program function.
"""
function main(args::Array{String})
  (cs::Vector{Float64}, x0s::Vector{Float64}, its::Int) = typed_globals()

  for (c, x0) in zip(cs, x0s)
    println("c=$c, x0=$x0, iterations=$its:")
    println("    $(f(x0, c, its))")
    println()
  end
end


# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end
