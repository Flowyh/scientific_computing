#=
  Rozwiązanie zadania 1. 2. 3. i 4. z listy zadań:
  https://cs.pwr.edu.pl/zielinski/lectures/scna/scnal4l.pdf

  Kurs: Obliczenia naukowe
  Prowadzący: prof. dr hab. Paweł Zieliński
  Data: 08.12.2022
  Autor: Maciej Bazela
  Nr. indeksu: 261743
  
  @Flowyh (https://github.com/Flowyh)
=#
module Interpolation

  using Plots
  using LaTeXStrings

  # Disable the warning about the GR backend
  ENV["GKSwstype"] = "100"

  export ilorazyRoznicowe, warNewton, naturalna
  export rysujNnfx
  export FloatVec

  # Type alias for Vector{Float64}
  const FloatVec = Vector{Float64}

  """
      ilorazyRoznicowe(x::FloatVec, f::FloatVec)::FloatVec
  
  Calculate the divided differences of the function `f` at the points `x`.

  ## Arguments:

  - `x::FloatVec`: Vector of points at which the function `f` is evaluated.
  - `f::FloatVec`: Vector of function values at the points `x`.

  ## Returns:

  - `fx::FloatVec`: Vector of divided differences of the function `f` at the points `x`.
  """
  function ilorazyRoznicowe(x::FloatVec, f::FloatVec)::FloatVec
    f_len = length(f)
    if (length(x) != f_len)
      return []
    end

    fx::FloatVec = [val for val in f]

    for i in 1:f_len
      for j in f_len:-1:i+1
        fx[j] = (fx[j] - fx[j-1]) / (x[j] - x[j-i])
      end
    end

    return fx
  end


  """
      warNewton(x::FloatVec, fx::FloatVec, t::Float64)::Float64

  Calculate the value of the Newton interpolation polynomial at the point `t`.

  ## Arguments:

  - `x::FloatVec`: Vector of points at which the function `f` is evaluated.
  - `fx::FloatVec`: Vector of divided differences of the function `f` at the points `x`.

  ## Returns:

  - `nt::Float64`: Value of the Newton interpolation polynomial at the point `t`.
  """
  function warNewton(x::FloatVec, fx::FloatVec, t::Float64)::Float64
    f_len = length(fx)
    if (length(x) != f_len)
      return 0.0
    end

    nt = fx[f_len]  
    for i in f_len-1:-1:1
      nt = fx[i] + (t - x[i]) * nt
    end
    return nt
  end

  """
      naturalna(x::FloatVec, fx::FloatVec)::FloatVec
    
  Calculate the coefficients of Newton's interpolation polynomial in the natural form.

  ## Arguments:

  - `x::FloatVec`: Vector of points at which the function `f` is evaluated.
  - `fx::FloatVec`: Vector of divided differences of the function `f` at the points `x`.

  ## Returns:

  - `a::FloatVec`: Vector of coefficients of Newton's interpolation polynomial in the natural form.
  """
  function naturalna(x::FloatVec, fx::FloatVec)::FloatVec
    f_len = length(fx)
    if (f_len != length(x))
      return []
    end

    a::FloatVec = zeros(length(fx))
    a[end] = fx[end]
    for i in f_len-1:-1:1
      a[i] = fx[i] - a[i+1] * x[i]  
      for j in i+1:f_len-1  
        a[j] = a[j] - a[j+1] * x[i]
      end
    end

    return a
  end

  ticks(min, max) = min:round((max - min) / 10.0, digits=2):max

  """
      rysujNnfx(f, a, b, n; f_name=L"f(x)", save_path="plot.svg")

  Plot the interpolation (using Newton's interpolation polynomial) of the function `f` 
  in the interval `[a, b]` using `n` points.
  The plot is saved to `save_path` file.

  ## Arguments:

  - `f::Function`: function to interpolate
  - `a::Float64`: left bound of the interval
  - `b::Float64`: right bound of the interval
  - `n::Int`: number of interpolation points

  ## Optional arguments:

  - `f_name::LaTeXString`: name of the function to interpolate as a LaTeX string
  - `save_path::String`: path to the file where the plot will be saved
  """
  function rysujNnfx(
    f::Function, 
    a::Float64, 
    b::Float64, 
    n::Int; 
    f_name::LaTeXString=L"f(x)",
    save_path::String="plot.svg"
  )
    if (a > b)
      a, b = b, a
    end

    # Density of the plot
    DENSITY::Int = 100

    dx::Float64 = (b - a) / Float64(n)
    xs::FloatVec = [a + i * dx for i in 0:n]
    ys::FloatVec = [f(x) for x in xs]

    ilorazy::FloatVec = ilorazyRoznicowe(xs, ys)

    dx = (b - a) / Float64(n * DENSITY)
    newton_xs::FloatVec = [a + i * dx for i in 0:n * DENSITY]
    newton_ys::FloatVec = [warNewton(xs, ilorazy, x) for x in newton_xs]

    fxs::FloatVec = [f(x) for x in newton_xs]

    ############
    # Plotting #
    ############

    min_x = a - abs(0.2a) - dx
    max_x = b + abs(0.2b) + dx
    minimum_ys = min(minimum(fxs), minimum(newton_ys))
    maximum_ys = max(maximum(fxs), maximum(newton_ys))
    min_y = round(minimum_ys - abs(0.2minimum_ys), digits=2)
    max_y = round(maximum_ys + abs(0.2maximum_ys), digits=2)
    xticks = ticks(a, b)
    yticks = ticks(min_y, max_y)
    
    # A bunch of options to make it look pretty
    pl = plot(
        newton_xs, 
        fxs; 
        title="Interpolation of $(f_name) using Newton's interpolation polynomial in $n points",
        xlims=(min_x, max_x),
        ylims=(min_y, max_y),
        xticks=xticks,
        yticks=yticks,
        label=f_name,
        legend=:topleft,
        legendfontsize=5,
        margin = 3Plots.mm,
        titlefontsize=9,
        titlealign=:center,
        framestyle=:zerolines,
        color=:orange
      )
    plot!(pl, newton_xs, newton_ys, label="Newton's interpolation", color=:red)
    # Interpolation points
    scatter!(pl, xs, ys, label="Interpolation points", color=:orange, markersize=3, markerstrokewidth=0.5)
    savefig(pl, save_path)
  end
end