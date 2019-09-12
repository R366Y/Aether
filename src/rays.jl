module Rays

using Aether.HomogeneousCoordinates
export Ray, positionr

struct Ray
    origin::Vec3D
    direction::Vec3D
end

function positionr(ray::Ray, t::T) where T <: AbstractFloat
    return ray.origin + ray.direction * t
end


end  # module Rays
