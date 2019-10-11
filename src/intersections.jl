module Intersections

export Intersection, hit

using LinearAlgebra
import Aether.BaseGeometricType: GeometricObject

struct Intersection{O<:GeometricObject}
    t::Float64
    object::O
end

function hit(is::Array)
    result::Union{Intersection, Nothing} = nothing
    min = Inf
    index = -1
    for (idx,val) in enumerate(is)
        if val.t >= 0. && val.t < min
            min = val.t
            index = idx
        end
    end
    if min < Inf
        result = is[index]
    end
    return result
end

end
