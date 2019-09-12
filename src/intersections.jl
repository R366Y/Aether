module Intersections

export Intersection

import Aether: GeometricObject

struct Intersection{T<:AbstractFloat, O<:GeometricObject}
    t::T
    object::O
end

end
