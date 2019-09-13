module Spheres

export Sphere, default_sphere, r_intersect

using Aether.HomogeneousCoordinates
using Aether.Rays
using Aether.Intersections
using LinearAlgebra
using StaticArrays
import Aether: float_equal, ϵ, GeometricObject

struct Sphere{T<:AbstractFloat} <: GeometricObject
    center::Vec3D
    radius::T
    transform::SMatrix

    function Sphere(center::Vec3D, radius::T) where T <: AbstractFloat
        new{T}(center, radius, SMatrix{4,4,T}(I))
    end
end

function default_sphere()
    return Sphere(point3D(0., 0., 0.), 1.)
end

function r_intersect(s::Sphere, r::Ray)
    sphere_to_ray = r.origin - s.center
    a = dot(r.direction, r.direction)
    b = 2. * dot(r.direction, sphere_to_ray)
    c = dot(sphere_to_ray, sphere_to_ray) - 1.

    discriminant = b^2 - 4. * a * c
    if discriminant < -ϵ
        return ()
    else
        t1 = (-b - √(discriminant)) / (2. * a)
        t2 = (-b + √(discriminant)) / (2. * a)
        return (Intersection(t1, s), Intersection(t2, s))
    end
end

end  # module Spheres
