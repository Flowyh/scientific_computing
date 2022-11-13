#=
  Rozwiązanie zadania 4. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal2l.pdf
  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 11.11.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743

  @Flowyh (https://github.com/Flowyh)
=#

using Polynomials


# Wilkinson polynomial coefficients
coefficients::Vector{Float64} = [
  1,
  -210.0,
  20615.0,
  -1256850.0,
  53327946.0,
  -1672280820.0,
  40171771630.0,
  -756111184500.0,
  11310276995381.0,
  -135585182899530.0,
  1307535010540395.0,
  -10142299865511450.0,
  63030812099294896.0,
  -311333643161390640.0,
  1206647803780373360.0,
  -3599979517947607200.0,
  8037811822645051776.0,
  -12870931245150988800.0,
  13803759753640704000.0,
  -8752948036761600000.0,
  2432902008176640000.0
]


# Wilkinson polynomial coefficients with one distorted value
coefficients_distorted::Vector{Float64} = [
  1,
  -210.0 - 2^(-23),
  20615.0,
  -1256850.0,
  53327946.0,
  -1672280820.0,
  40171771630.0,
  -756111184500.0,
  11310276995381.0,
  -135585182899530.0,
  1307535010540395.0,
  -10142299865511450.0,
  63030812099294896.0,
  -311333643161390640.0,
  1206647803780373360.0,
  -3599979517947607200.0,
  8037811822645051776.0,
  -12870931245150988800.0,
  13803759753640704000.0,
  -8752948036761600000.0,
  2432902008176640000.0
]

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
  wilkinson_normal_poly(coeffs)::Polynomial = Polynomial(reverse(coeffs))
  wilkinson_roots::ComposedFunction = roots ∘ wilkinson_normal_poly

  function wilkinson_prod_poly(x, type)
    result = type(1)
    for i in 1:20
      result *= (x - type(i))
    end
    return result
  end

  return (wilkinson_normal_poly, wilkinson_roots, wilkinson_prod_poly)
end


"""
Print formatted latex table row.
"""
latex_table_row((k, Zk, PZk, pZk, Zk_k)) = println("\$$k\$ & \$$Zk\$ & \$$PZk\$ & \$$pZk\$ & \$$Zk_k\$ \\\\")


"""
    wilkinson_polynomial_test(coeffs::Vector{Float64})

Finds roots of wilkinson polynomial (`P`) and compute `P(zk)` for each root `zk`.
Computes same results using the normal form (`p`) of `P`
Prints results to the console.
"""
function wilkinson_polynomial_test(coeffs::Vector{Float64})
  (wilkinson_normal_poly, wilkinson_roots, wilkinson_prod_poly) = typed_globals()

  roots = wilkinson_roots(coeffs)
  wilkinson_poly = wilkinson_normal_poly(coeffs)
  wilkinson_prod = wilkinson_prod_poly

  for k in 1:20
    root = roots[k]
    PZk = abs(wilkinson_poly(root))
    pZk = abs(wilkinson_prod(root, typeof(root)))
    zk_minus_k = abs(root - k)
    println("K=$k, Zk=$(root):")
    println("    |P(Zk)|=$PZk")
    println("    |p(Zk)|=$pZk")
    println("    |Zk-k|=$zk_minus_k")
  end
end


"""
Prints formatted LaTex table for this task.
"""
function latex_table(coeffs)
  (wilkinson_normal_poly, wilkinson_roots, wilkinson_prod_poly) = typed_globals()

  roots = wilkinson_roots(coeffs)
  wilkinson_poly = wilkinson_normal_poly(coeffs)
  wilkinson_prod = wilkinson_prod_poly

  for k in 1:20
    root = roots[k]
    PZk = abs(wilkinson_poly(root))
    pZk = abs(wilkinson_prod(root, typeof(root)))
    zk_minus_k = abs(root - Complex(k))
    latex_table_row((k, root, PZk, pZk, zk_minus_k))
  end
end


"""
Main program function.
"""
function main(args::Vector{String})
  wilkinson_polynomial_test(coefficients)
  println()
  wilkinson_polynomial_test(coefficients_distorted)
  # latex_table(coefficients)
  # latex_table(coefficients_distorted)
end

# Equivalent to Pythonic "if __name__ == "__main__":
if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end
