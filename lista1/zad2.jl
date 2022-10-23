#=
  Rozwiązanie zadania 2. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal1l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 21.10.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#

# Type alias for all Floats, probably same as AbstractFloat, but I'd rather be sure
Floats = Union{Float16, Float32, Float64}

"""
    kahan(float_type::Float16)
    kahan(float_type::Float32)
    kahan(float_type::Float64)

Calculates `3 * (4 / 3 - 1)` + 1 for given `Float` type.
It is supposed to be an equivalent of `Base.eps(float_type)`.

## Returns:

- Machine epsilon approximation
"""
function kahan(float_type::Type{<:Floats})
  three = float_type(3)
  four = float_type(4)
  _one = one(float_type)
  return three * (four / three - _one) - _one
end

"""
Main program function.
"""
function main(args::Array{String})
  for float_type in [Float16, Float32, Float64]
    macheps = eps(float_type)
    _kahan = kahan(float_type)
    println("Type = $(Symbol(float_type))")
    println("Macheps = $(macheps)")
    println("          $(bitstring(macheps))")
    println("Kahan = $(_kahan)")
    println("          $(bitstring(_kahan))")
    println("Equal? $(macheps == _kahan)")
    println()
  end
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end