__precompile__(true)

module RayTracer
    include("homogeneous_coordinates.jl")
    include("colors.jl")
    include("canvas.jl")
    include("matrix_transformations.jl")
end
