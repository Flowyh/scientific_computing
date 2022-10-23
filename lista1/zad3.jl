#=
  Rozwiązanie zadania 3. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal1l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 21.10.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#

"""
    floating_distance(_start::Float64, _end::Float64)

Calculates distance between two numbers for given [_start, _end] range.
The difference between _start's and _end's IEEE 754 exponents has to be
equal to 1, because otherwise the distance between two floating point numbers
in [_start, _end] range cannot be split evenly.

This function is just a helper function to be loaded into REPL
when presenting task 3. from this list.

## Arguments:

- `_start::Float64` - checked range start
- `_end::Float64` - checked range end

## Returns:

- Distance between two floating point numbers in given range
"""
floating_distance(_start::Float64, _end::Float64) =
  exponent(_start) + 1 != exponent(_end) ? 
  throw("Exponent mismatch, range may be uneven.") : 
  (Float64(2.0)^exponent(_start)) * (Float64(2.0)^(-52))