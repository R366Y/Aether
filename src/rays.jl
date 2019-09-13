module Rays

export Ray, positionr, transform

using StaticArrays
using LinearAlgebra
using Aether.HomogeneousCoordinates

struct Ray
    origin::Vec3D
    direction::Vec3D
end

function positionr(ray::Ray, t::T) where T <: AbstractFloat
    return ray.origin + ray.direction * t
end

function transform(ray::Ray, matrix::SMatrix)
     origin = matrix * ray.origin
     direction = matrix * ray.direction
     return Ray(origin, direction)
end

end  # module Rays
