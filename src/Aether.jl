module Aether

export ϵ, float_equal, ObjFile, parse_obj_file

const ϵ = 0.00001

function float_equal(a::T, b::T) where {T<:AbstractFloat}
    if abs(a - b) < ϵ
        return true
    else
        return false
    end
end

include("utils.jl")

include("homogeneous_coordinates.jl")
include("matrix_transformations.jl")
include("rays.jl")
include("base_geometric_type.jl")
include("colors.jl")
include("canvas.jl")
include("lights.jl")
include("patterns.jl")
include("materials.jl")
include("computations.jl")

include("camera.jl")
include("shaders.jl")

include("shapes.jl")
include("wavefront_obj_reader.jl")

include("world.jl")

end # module
