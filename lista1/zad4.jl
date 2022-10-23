#=
  Rozwiązanie zadania 4. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal1l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 21.10.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#

"""
    smallest_not_equal_to_one(_start::Float64, limit::Float64)

Calculates the smallest number x in range [_start, limit] that does not
follow the identity: x * (1/ x) == 1.

It's a number that due to floating point rounding errors breaks the above
simple equation.

This algorithm can be speed up, but I've opted to brute-force, because
it doesn't take that long to compute.

## Arguments:

- `_start::Float64` - checked range start
- `limit::Float64` - checked range end

## Returns:

- Smallest number x which breaks indentity x * (1 / x) == 1
"""
function smallest_not_equal_to_one(_start::Float64, limit::Float64=Inf64)
  curr = _start
  next = nextfloat(curr)
  _one = one(Float64)

  while next * (_one / next) == _one && curr < limit
    curr = next
    next = nextfloat(curr)
  end
  return next
end

"""
    smallest_not_equal_to_one_and_inf(_start::Float64, limit::Float64)

An extension of `smallest_not_equal_to_one` function.

It introduces another check in the while loop that forbids (x * 1 / x) to be 
rounded to infinity (Inf64).

## Arguments:

- `_start::Float64` - checked range start
- `limit::Float64` - checked range end

## Returns:

- Smallest number x which breaks identities x * (1 / x) == 1 and x * (1 / x) == Inf
"""
function smallest_not_equal_to_one_and_inf(_start::Float64, limit::Float64=Inf64)
  curr = _start
  next = nextfloat(curr)
  _one = one(Float64)

  while (next *  (_one / next)) == Inf64 || (next * (_one / next) == _one && curr < limit)
    curr = next
    next = nextfloat(curr)
    println(next)
  end
  return next
end

"""
Main program function.
"""
function main(args::Array{String})
  x::Float64 = smallest_not_equal_to_one(one(Float64), Float64(2))
  println("Found x, such that 1 < x < 2 and x * (1 / x) != 1")
  println("      x=$(x), bitstring=[$(bitstring(x))], x * (1 / x) = $(x * (one(Float64) / x))")
  x = smallest_not_equal_to_one(zero(Float64))
  println("Smallest x that x * (1 / x) != 1")
  println("      x=$(x), bitstring=[$(bitstring(x))], x * (1 / x) = $(x * (one(Float64) / x))")
  x = smallest_not_equal_to_one_and_inf(zero(Float64))
  println("Smallest x that x * (1 / x) != 1")
  println("      x=$(x), bitstring=[$(bitstring(x))], x * (1 / x) = $(x * (one(Float64) / x))")
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end