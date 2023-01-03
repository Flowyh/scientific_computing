julia --project=. -e 'using Pkg; Pkg.activate(); Pkg.instantiate();'
echo "Running main.jl with arguments: $1 $2 $3 $4"
julia --project=. main.jl $1 $2 $3 $4