import Aether: ϵ
import Aether.BaseGeometricType: GeometricObject, local_intersect,
                                 local_normal_at
import Aether.HomogeneousCoordinates: point3D, vector3D, Vec3D
import Aether.Intersections: Intersection
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

mutable struct Plane <: GeometricObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material

    function Plane()
        new(identity_matrix(Float64), identity_matrix(Float64),
            default_material())
    end
end

function local_normal_at(plane::Plane, point::Vec3D)
    return vector3D(0., 1., 0.)
end

function local_intersect(plane::Plane, ray::Ray)
    result = ()
    if abs(ray.direction.y) < ϵ
        return result
    end
    t = -ray.origin.y / ray.direction.y
    result = (Intersection(t, plane),)
    return result
end
