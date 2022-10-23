#=
  Rozwiązanie zadania 1. z listy zadań:
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
    two(float_type::Float16)
    two(float_type::Float32)
    two(float_type::Float64)

Simply returns float_type(2) for given Float type.
"""
two(float_type::Type{<:Floats}) = float_type(2)

"""
    macheps(float_type::Float16)
    macheps(float_type::Float32)
    macheps(float_type::Float64)

Calculates machine epsilon (ref: https://en.wikipedia.org/wiki/Machine_epsilon) 
for given floating type. Equivalent to `Base.eps`.

## Arguments:

- `float_type::Type{<:Floats}` - floating point type

## Returns:

- Machine epsilon for given FloatX type.

# Examples
```julia-repl
julia> macheps(Float64)
2.220446049250313e-16
```
"""
function macheps(float_type::Type{<:Floats})::float_type
  _one = oneunit(float_type)
  _eps = _one
  _two = two(float_type)

  while true
    (_one + (_eps / _two) != _one) || break
    _eps /= _two
  end

  return _eps
end

"""
    eta(float_type::Float16)
    eta(float_type::Float32)
    eta(float_type::Float64)

Calculates the smallest (subnormal) floating point number. Equivalent to `Base.nextfloat(0.0)`.

## Arguments:

- `float_type::Type{<:Floats}` - floating point type

## Returns:

- The smallest subnormal floating point number.

# Examples
```julia-repl
julia> eta(Float64)
5.0e-324
"""
function eta(float_type::Type{<:Floats})::float_type
  _zero = zero(float_type)
  _eta = oneunit(float_type)
  _two = two(float_type)

  while true
    (_zero + (_eta / _two) != _zero) || break
    _eta /= _two
  end

  return _eta
end

"""
    float_max(float_type::Float16)
    float_max(float_type::Float32)
    float_max(float_type::Float64)

Calculates the largest floating point number. Equivalent to `Base.floatmax`.

## Arguments:

- `float_type::Type{<:Floats}` - floating point type

## Returns:

- Largest floating point number for given FloatX

# Examples
```julia-repl
julia> float_max(Float64)
1.7976931348623157e308
"""
function float_max(float_type::Type{<:Floats})::float_type
  _float_max::float_type = oneunit(float_type)
  _two = two(float_type)

  while (!isinf(_float_max * _two))
    _float_max *= _two
  end

  curr_mantissa = _float_max / _two
  while (!isinf(_float_max + curr_mantissa))
    _float_max += curr_mantissa
    curr_mantissa /= _two
  end

  return _float_max
end

"""
Main program function.
"""
function main(args::Array{String})
  # I'm too lazy to make it generic, so enjoy 13 prints per step
  for float in [Float16, Float32, Float64]
    println("$(Symbol(float)):")
    
    println("   macheps:")
    _macheps = macheps(float)
    _eps = eps(float)
    println("     (My impl) macheps($(float))=$(_macheps)")
    println("     (Lib)     eps($(float))=$(_eps)")
    println("               Equal? $(_macheps == _eps)")
    
    println("   eta:")
    _eta = eta(float)
    _nextfloat = nextfloat(float(0.0))
    println("     (My impl) eta($(float))=$(_eta)")
    println("     (Lib)     nextfloat($(float)(0.0))=$(_nextfloat)")
    println("               Equal? $(_eta == _nextfloat)")

    println("   floatmax:")
    _float_max = float_max(float)
    _floatmax = floatmax(float)
    println("     (My impl) float_max($(float))=$(_float_max)")
    println("     (Lib)     floatmax($(float))=$(_floatmax)")
    println("               Equal? $(_float_max == _floatmax)")
  end
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end