module Spheres

export Sphere, default_sphere, r_intersect

using Aether.HomogeneousCoordinates
using Aether.Rays
using LinearAlgebra
import Aether: float_equal, ϵ

struct Sphere{T<:AbstractFloat}
    center::Vec3D
    radius::T
end

function default_sphere()
    return Sphere(point3D(0.,0.,0.), 1.)
end

function r_intersect(s::Sphere, r::Ray)
    sphere_to_ray::Vec3D = r.origin - s.center
    a::Float64 = dot(r.direction, r.direction)
    b::Float64 = 2 * dot(r.direction, sphere_to_ray)
    c::Float64 = dot(sphere_to_ray, sphere_to_ray) - 1

    discriminant::Float64 = b^2 - 4 * a * c
    if discriminant < -ϵ
        return ()
    else
        t1::Float64 = (-b -√(discriminant)) / 2 * a
        t2::Float64 = (-b +√(discriminant)) / 2 * a
        return (t1, t2)
    end
end

end  # module Spheres
