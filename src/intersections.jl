module Intersections

export Intersection, hit, reflect

using LinearAlgebra

using Aether.HomogeneousCoordinates
import Aether: GeometricObject

struct Intersection{T<:AbstractFloat, O<:GeometricObject}
    t::T
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

function reflect(v::Vec3D, normal::Vec3D)
    return v - normal * 2. * dot(v, normal)
end

end
