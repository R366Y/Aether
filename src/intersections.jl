module Intersections

export Intersection, hit

using LinearAlgebra

using Aether.HomogeneousCoordinates
import Aether: GeometricObject

struct Intersection{O<:GeometricObject}
    t::Float64
    object::O
end

function hit(is::Tuple{Vararg{Intersection}})
    t_values = [h.t for h in is if h.t>=0.]
    if length(t_values) == 0
        return nothing
    else
        idx = findmin(t_values)[2]
        return is[idx]
    end
end

end
