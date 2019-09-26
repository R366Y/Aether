module Spheres

export Sphere, default_sphere

using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Rays

using LinearAlgebra
using StaticArrays
import Aether: float_equal, ϵ
import Aether.BaseGeometricType: GeometricObject, set_transform,
                                 local_intersect, local_normal_at
import Base: ==

mutable struct Sphere <: GeometricObject
    center::Vec3D{Float64}
    radius::Float64
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material

    function Sphere(center::Vec3D, radius::Float64)
        new(center, radius, identity_matrix(Float64), identity_matrix(Float64), default_material())
    end
end

@inline ==(s1::Sphere, s2::Sphere) = s1.center == s2.center &&
                                     s1.radius == s2.radius &&
                                     s1.transform == s2.transform


function default_sphere()
    return Sphere(point3D(0., 0., 0.), 1.)
end

function local_intersect(s::Sphere, r::Ray)
    #r = transform(r, s.inverse)
    sphere_to_ray = r.origin - s.center
    a = dot(r.direction, r.direction)
    b = 2. * dot(r.direction, sphere_to_ray)
    c = dot(sphere_to_ray, sphere_to_ray) - 1.

    discriminant = b^2 - 4. * a * c
    result = Intersection{Sphere}[]
    if discriminant >= 0.
        t1 = (-b - √(discriminant)) / (2. * a)
        t2 = (-b + √(discriminant)) / (2. * a)
        push!(result, Intersection(t1, s), Intersection(t2, s))
    end
    return result
end

# function normal_at(sphere::Sphere, world_point::Vec3D)
#     object_point = sphere.inverse * world_point
#     object_normal = object_point - sphere.center
#     world_normal = transpose(sphere.inverse) * object_normal
#     world_normal.w = 0.
#     return normalize(world_normal)
# end

function local_normal_at(sphere::Sphere, local_point::Vec3D)
    return local_point - sphere.center
end

end  # module Spheres
