module Intersections

export Intersection, hit

import Aether: GeometricObject

struct Intersection{T<:AbstractFloat, O<:GeometricObject}
    t::T
    object::O
end

function hit(is::Tuple{Vararg{Intersection}})
    idx = 1
    t_min = Inf
    for i in eachindex(is)
        t = is[i].t
        if t > 0. && t < t_min
            idx = i
            t_min = is[idx].t
        end
    end
    if t_min === Inf
        return nothing
    end
    return is[idx]
end

end
