module Aether

export ϵ, float_equal

const ϵ = 0.00001

function float_equal(a::T, b::T) where T <: AbstractFloat
    if abs(a - b) < ϵ
        return true
    else
        return false
    end
end

include("homogeneous_coordinates.jl")
include("colors.jl")
include("canvas.jl")
include("matrix_transformations.jl")
include("rays.jl")
include("spheres.jl")


end # module