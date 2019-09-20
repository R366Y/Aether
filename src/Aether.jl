module Aether

export ϵ, float_equal, GeometricObject

abstract type GeometricObject end

const ϵ = 0.00001

function float_equal(a::T, b::T) where T <: AbstractFloat
    if abs(a - b) < ϵ
        return true
    else
        return false
    end
end

include("homogeneous_coordinates.jl")
include("matrix_transformations.jl")
include("colors.jl")
include("materials.jl")
include("rays.jl")
include("camera.jl")
include("canvas.jl")
include("lights.jl")
include("shaders.jl")

include("intersections.jl")
include("spheres.jl")
include("computations.jl")

include("world.jl")

end # module
