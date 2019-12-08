module Aether

export ϵ, float_equal, ObjFile, obj_to_group, parse_obj_file

using Reexport

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
include("csg.jl")
include("wavefront_obj_reader.jl")

include("world.jl")

include("bounding_box.jl")

# Horrible way to simulate cyclical module dependencies that are not
# supported in Julia. I need to use bounding box inside groups.jl but
# but bounding box to work needs both groups and shapes.
@reexport using Aether.AccelerationStructures
end # module
