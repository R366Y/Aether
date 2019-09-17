module Spheres

export Sphere, default_sphere, r_intersect, normal_at, set_transform

using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Rays

using LinearAlgebra
using StaticArrays
import Aether: float_equal, ϵ, GeometricObject

mutable struct Sphere <: GeometricObject
    center::Vec3D{Float64}
    radius::Float64
    transform::SMatrix{4,4,Float64}
    inverse::SMatrix{4,4,Float64}
    material::Material

    function Sphere(center::Vec3D, radius::Float64)
        new(center, radius, identity_matrix(Float64), identity_matrix(Float64), default_material())
    end
end

function default_sphere()
    return Sphere(point3D(0., 0., 0.), 1.)
end

function set_transform(sphere::Sphere, matrix::SMatrix{4,4,Float64})
    sphere.transform = matrix
    sphere.inverse = inv(matrix)
end

function r_intersect(s::Sphere, r::Ray)
    r = transform(r, s.inverse)

    sphere_to_ray = r.origin - s.center
    a = dot(r.direction, r.direction)
    b = 2. * dot(r.direction, sphere_to_ray)
    c = dot(sphere_to_ray, sphere_to_ray) - 1.

    discriminant = b^2 - 4. * a * c
    t1 = 0.
    t2 = 0.
    if discriminant >= 0.
        t1 = (-b - √(discriminant)) / (2. * a)
        t2 = (-b + √(discriminant)) / (2. * a)
        return (Intersection(t1, s), Intersection(t2, s))
    end
    return ()
end

function normal_at(sphere::Sphere, world_point::Vec3D)
    object_point = sphere.inverse * world_point
    object_normal = object_point - sphere.center
    world_normal = transpose(sphere.inverse) * object_normal
    world_normal.w = 0.
    return normalize(world_normal)
end


end  # module Spheres
