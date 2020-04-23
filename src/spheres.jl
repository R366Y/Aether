import Base: ==
import Aether: float_equal, ϵ
import Aether.BaseGeometricType: GeometricObject,
                                 set_transform,
                                 local_intersect,
                                 local_normal_at,
                                 Intersection,
                                 GroupType
import Aether.HomogeneousCoordinates: Vec3D, point3D, dot
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

mutable struct Sphere <: GeometricObject
    center::Vec3D
    radius::Float64
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    parent::Union{GroupType,Nothing}
    shadow::Bool

    function Sphere(center::Vec3D, radius::Float64)
        new(
            center,
            radius,
            identity_matrix(),
            identity_matrix(),
            default_material(),
            nothing,
            true
        )
    end
end

@inline ==(s1::Sphere, s2::Sphere) =
    s1.center == s2.center &&
    s1.radius == s2.radius && s1.transform == s2.transform


function default_sphere()
    return Sphere(point3D(0.0, 0.0, 0.0), 1.0)
end

function glass_sphere()
    s = default_sphere()
    s.material.transparency = 1.0
    s.material.refractive_index = 1.5
    return s
end

function local_intersect(s::Sphere, r::Ray)
    sphere_to_ray = r.origin - s.center
    a = dot(r.direction, r.direction)
    b = 2.0 * dot(r.direction, sphere_to_ray)
    c = dot(sphere_to_ray, sphere_to_ray) - 1.0

    discriminant = b^2 - 4.0 * a * c
    result = ()
    if discriminant >= 0.0
        sqrt_disc = √(discriminant)
        den = (2.0 * a)
        t1 = (-b - sqrt_disc) / den
        t2 = (-b + sqrt_disc) / den
        result = (Intersection(t1, s), Intersection(t2, s))
    end
    return result
end

function local_normal_at(sphere::Sphere, local_point::Vec3D)
    return local_point - sphere.center
end
