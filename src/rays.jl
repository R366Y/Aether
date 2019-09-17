module Rays

export Ray, positionr, transform, reflect

using StaticArrays
using LinearAlgebra
using Aether.HomogeneousCoordinates

struct Ray
    origin::Vec3D{Float64}
    direction::Vec3D{Float64}
end

function positionr(ray::Ray, t::Float64)
    return ray.origin + ray.direction * t
end

function transform(ray::Ray, matrix::SMatrix)
     origin = matrix * ray.origin
     direction = matrix * ray.direction
     return Ray(origin, direction)
end

function reflect(v::Vec3D, normal::Vec3D)
    return v - normal * 2. * dot(v, normal)
end
end  # module Rays
