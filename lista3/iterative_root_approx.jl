#=
  Rozwiązanie zadania 1. 2. i 3. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal3l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 19.11.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#
module IterativeRootApprox

  export mbisekcji, mstycznych, msiecznych
  export IRAResults
  export IRAR_ERROR_CODE_ONE, IRAR_ERROR_CODE_TWO
  export pretty_results_print, results_latex_row

  """
  Struct holding final results of iterative root approximation algorithm.
  """
  struct IRAResults
    root::Float64
    f_root::Float64
    iteration::Int
    error_code::UInt8
  end

  # Error code 1 (Bisekcja: same sign in f(a) and f(b), Newton/Styczne: maxit exceeded)
  const IRAR_ERROR_CODE_ONE::IRAResults = IRAResults(.0, .0, 0, 1)
  # Error code 2 (Newton: derivative close to 0)
  const IRAR_ERROR_CODE_TWO::IRAResults = IRAResults(.0, .0, 0, 2)

  """
      pretty_results_print(results::IRAResults, name::String)

  Prints results of iterative root approximation algorithm in a pretty way.

  ## Arguments:

  - `results::IRAResults` - root approximation algorithm result
  - `name::String` - name of the algorithm
  """
  function pretty_results_print(results::IRAResults, name::String)
    println("Function: $(name)")
    println("          root: $(results.root)")
    println("       f(root): $(results.f_root)")
    println("    iterations: $(results.iteration)")
    println("    error_code: $(results.error_code)")
  end

  """
      results_latex_row(results::IRAResults)

  Prints results of iterative root approximation algorithm as a latex table row.

  ## Arguments:

  - `results::IRAResults` - root approximation algorithm result
  """
  function results_latex_row(results::IRAResults)
    println("\$$(results.root)\$ & \$$(results.f_root)\$ & \$$(results.iteration)\$ & \$$(results.error_code)\$ \\\\")
  end

  """
      mbisekcji(f::Function, a::Float64,  b::Float64,  
      delta::Float64, epsilon::Float64)::IRAResults

  Bisection root approximation algorithm. 
  `f` has to be continuous between `a` and `b`. 
  `f(a)` and `f(b)` have to have opposite signs.

  If `f(a)` and `f(b)` have the same signs return `IRAR_ERROR_CODE_ONE`.

  We start from computing the middle of [a, b] interval and check,
  whether `f(a)` and `f(middle)` or `f(b)` and `f(middle)` have opposite signs.
  
  If the first occurs, we choose [a, middle] as our next interval and proceed
  with same steps in the next iteration.

  Otherwise we choose [middle, b] and do the same.

  During each iteration we have to check, whether we've already achieved
  desired accuracy: if `|f(middle)| <= delta` or `|b - a| <= epsilon`
  return the `middle, fmiddle, iteration` as our result.

  ## Arguments:

  - `f::Function` - continuous function on [a, b] interval
  - `a::Float64` - start of the searched interval
  - `b::Float64` - end of the searched interval
  - `delta::Float64` - `f(root) = 0` accuracy
  - `epsilon::Float64` - interval length accuracy
  """
  function mbisekcji(
    f::Function,
    a::Float64, 
    b::Float64, 
    delta::Float64, 
    epsilon::Float64
  )::IRAResults
    if a > b
      a, b = b, a
    end
    fa::Float64 = f(a)
    fb::Float64 = f(b)
    
    if (sign(fa) == sign(fb))
      return IRAR_ERROR_CODE_ONE
    end

    dist::Float64 = b - a
    iteration::Int = 1

    middle::Float64 = 0.0
    fmiddle::Float64 = 0.0

    while true
      dist /= 2
      middle = a + dist
      fmiddle = f(middle)

      if (abs(dist) <= delta || abs(fmiddle) <= epsilon)
        return IRAResults(middle, fmiddle, iteration, 0)
      end

      if sign(fmiddle) != sign(fa)
        b, fb = middle, fmiddle
      else
        a, fa = middle, fmiddle
      end

      iteration += 1
    end
  end

  """
      mstycznych(f::Function, pf::Float64, x0::Float64, 
      delta::Float64, epsilon::Float64, maxit::Int)::IRAResults

  Newton root approximation algorithm. 
  `f` has to be twice differentiable. And `f(r) != 0` (r is a single root).

  This method uses the linearization of the first two components of the 
  Taylor series: f(x) ≈ f(x_n) + f'(x_n)(x - x_n)

  x_n is the n-th approximation of `f`'s root computed using below formula:

  x_n+1 = x_n - f(x_n) / f'(x_n)

  `x_0` is given as a function parameter (`x0`).

  During each iteration step we have to check, if `|f'(x_n)| <= epsilon`.
  If yes, we cannot use above `x_n+1` formula, as `f'` is approaching 0.
  Return `IRAR_ERROR_CODE_TWO` if above happens.

  During each iteration we have to check, whether we've already achieved
  desired accuracy: if `|f(x_n)| <= epsilon` or `|x_n - x_n-1| <= delta`
  return the `x_n, f(x_n), iteration` as our result.

  If we exceed maximum number of iteration (`maxit`) return `IRAR_ERROR_CODE_ONE`.

  ## Arguments:

  - `f::Function`      - twice differentiable function
  - `pf::Float64`      - continuous derivative, where `f(r) != 0`
  - `x0::Float64`      - first root approximation
  - `delta::Float64`   - `x_n - x_n-1` accuracy
  - `epsilon::Float64` - `f(root) = 0` accuracy
  - `maxit::Int`       - max number of iterations
  """
  function mstycznych(
    f::Function,
    pf::Function,
    x0::Float64, 
    delta::Float64, 
    epsilon::Float64, 
    maxit::Int
  )::IRAResults
    if (abs(pf(x0)) <= epsilon) # x0 nie jest pierwiastkiem jednokrotnym
      return IRAR_ERROR_CODE_TWO
    end
  
    fx = f(x0)
    if (abs(fx) <= epsilon)
      return IRAResults(x0, fx, 0, 0)
    end

    x1::Float64 = 0.0
    for iteration::Int = 1:maxit
      if (abs(pf(x0)) <= epsilon) # x0 nie jest pierwiastkiem jednokrotnym
        return IRAR_ERROR_CODE_TWO
      end

      x1 = x0 - (fx / pf(x0))
      fx = f(x1)
      
      if (abs(x1 - x0) <= delta || abs(fx) <= epsilon)
        return IRAResults(x1, fx, iteration, 0)
      end

      x0 = x1
    end

    return IRAR_ERROR_CODE_ONE
  end


  """
      msiecznych(f::Function, x0::Float64, x1::Float64,
      delta::Float64, epsilon::Float64, maxit::Int)::IRAResults

  Secant method root approximation algorithm. 
  `f` has to be twice differentiable. And `f(r) != 0` (r is a single root).

  This method computes a secnat going through two points (x_n, f(x_n)) and
  (x_n-1, f(x_n-1)) and uses it's x-intercept point as the root approximation.

  It is essentially the same as Newton's method, but we approximate f's derivative
  using below formula:

  f'(x) ≈ (f(x_n) - f(x_n-1)) / (x_n - x_n-1)

  We can then replace x_n's formula with the one below:

  x_n+1 = x_n - ((x_n - x_n-1)/(f(x_n) - f(x_n-1))) * f(x_n)

  `x_0` and `x_1` are given as a function parameters (`x0`, `x1`).

  During each iteration we have to check, whether we've already achieved
  desired accuracy: if `|f(x_n)| <= epsilon` or `|x_n+1 - x_n| <= delta`
  return the `x_n, f(x_n), iteration` as our result.

  If we exceed maximum number of iteration (`maxit`) return `IRAR_ERROR_CODE_ONE`.=

  ## Arguments:

  - `f::Function`      - twice differentiable function
  - `x0::Float64`      - first secant starting point
  - `x1::Float64`      - second secant starting point
  - `delta::Float64`   - `x_n - x_n-1` accuracy
  - `epsilon::Float64` - `f(root) = 0` accuracy
  - `maxit::Int`       - max number of iterations
  """
  function msiecznych(
    f::Function, 
    x0::Float64, 
    x1::Float64, 
    delta::Float64, 
    epsilon::Float64,
    maxit::Int
  )::IRAResults
    if x0 > x1
      x0, x1 = x1, x0
    end

    fa::Float64 = f(x0)
    fb::Float64 = f(x1)
    s::Float64 = 0.0

    for iteration::Int = 1:maxit
      if (abs(fa) > abs(fb))
        x0, x1 = x1, x0
        fa, fb = fb, fa
      end
      s = (x1 - x0) / (fb - fa)
      x1 = x0
      fb = fa
      x0 -= fa * s
      fa = f(x0)
      if (abs(x1 - x0) <= delta || abs(fa) <= epsilon)
        return IRAResults(x0, fa, iteration, 0)
      end
    end

    return IRAR_ERROR_CODE_ONE
  end
end