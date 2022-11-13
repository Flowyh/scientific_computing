#=
  Rozwiązanie zadania 5. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal2l.pdf
  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 11.11.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743

  @Flowyh (https://github.com/Flowyh)
=#

"""
    population_growth_model()

Simple recursive logistic model implementation.

p_(n+1) = p_n + r * p_n * (1 - p_n), for n = 0, 1, ...
and r is a constant.
"""
function population_growth_model(
  n::Int,
  r::Union{Float32, Float64},
  p0::Union{Float32, Float64}
)::Union{Float32, Float64}
  if (n == 0)
    return p0
  end
  pn_1::Union{Float32, Float64} = population_growth_model(n - 1, r, p0)
  return pn_1 + r * pn_1 * (1 - pn_1)
end


"""
Compute experiments described in this task.
"""
function experiments()
  f32_40it = population_growth_model(40, Float32(3), Float32(0.01))
  f64_40it = population_growth_model(40, Float64(3), Float64(0.01))

  f32_40it_truncated_once = population_growth_model(10, Float32(3), Float32(0.01))
  f32_40it_truncated_once = population_growth_model(30, Float32(3), Float32(trunc(f32_40it_truncated_once, digits=3, base=10)))
 
  f64_40it_truncated_once = population_growth_model(10, Float64(3), Float64(0.01))
  f64_40it_truncated_once = population_growth_model(30, Float64(3), Float64(trunc(f64_40it_truncated_once, digits=3, base=10)))

  f32_40it_truncated = population_growth_model(10, Float32(3), Float32(0.01))
  f32_40it_truncated = population_growth_model(10, Float32(3), Float32(trunc(f32_40it_truncated, digits=3, base=10)))
  f32_40it_truncated = population_growth_model(10, Float32(3), Float32(trunc(f32_40it_truncated, digits=3, base=10)))
  f32_40it_truncated = population_growth_model(10, Float32(3), Float32(trunc(f32_40it_truncated, digits=3, base=10)))

  f64_40it_truncated = population_growth_model(10, Float64(3), Float64(0.01))
  f64_40it_truncated = population_growth_model(10, Float64(3), Float64(trunc(f64_40it_truncated, digits=3, base=10)))
  f64_40it_truncated = population_growth_model(10, Float64(3), Float64(trunc(f64_40it_truncated, digits=3, base=10)))
  f64_40it_truncated = population_growth_model(10, Float64(3), Float64(trunc(f64_40it_truncated, digits=3, base=10)))

  return (f32_40it, f64_40it, f32_40it_truncated_once, f64_40it_truncated_once, f32_40it_truncated, f64_40it_truncated)
end


"""
Main program function.
"""
function main(args::Array{String})
  experiment_names = [
    "Float32 40 iterations",
    "Float64 40 iterations",
    "Float32 40 iterations truncated after 10 iterations",
    "Float64 40 iterations truncated after 10 iterations",
    "Float32 40 iterations truncated every 10 iterations",
    "Float64 40 iterations truncated every 10 iterations",
  ]
  for (res, name) in zip(experiments(), experiment_names)
    println("$name: $res")
  end
end


# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end