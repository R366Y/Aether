module Rays

export Ray, positionr, transform, reflect

using StaticArrays
using LinearAlgebra
using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations

struct Ray
    origin::Vec3D
    direction::Vec3D
end

function positionr(ray::Ray, t::Float64)
    return ray.origin + ray.direction * t
end

function transform(ray::Ray, matrix::Matrix4x4)
    origin = matrix * ray.origin
    direction = matrix * ray.direction
    return Ray(origin, direction)
end

function reflect(v::Vec3D, normal::Vec3D)
    return v - normal * 2.0 * dot(v, normal)
end
end
