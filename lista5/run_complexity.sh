julia --project=. -e 'using Pkg; Pkg.activate(); Pkg.instantiate();'
echo "Running complexity.jl with arguments: $1 $2 $3 $4 $5 $6 $7 $8 $9"
julia --project=. complexity.jl $1 $2 $3 $4 $5 $6 $7 $8 $9