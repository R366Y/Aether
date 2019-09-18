module Intersections

export Intersection, hit

using LinearAlgebra
import Aether: GeometricObject

struct Intersection{O<:GeometricObject}
    t::Float64
    object::O
end

function hit(is::Tuple{Vararg{Intersection}})
    t_values = [h for h in is if h.t>=0.]
    if length(t_values) == 0
        return nothing
    else
        sort!(t_values, by = i->i.t)
        return t_values[1]
    end
end

end
