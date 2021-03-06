import Aether: ϵ
import Aether.BaseGeometricType: GeometricObject,
                                 local_intersect,
                                 local_normal_at,
                                 Intersection,
                                 GroupType
import Aether.HomogeneousCoordinates: point3D, vector3D, Vec3D
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

mutable struct Plane <: GeometricObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    parent::Union{GroupType,Nothing}
    shadow::Bool

    function Plane()
        new(
            identity_matrix(),
            identity_matrix(),
            default_material(),
            nothing,
            true
        )
    end
end

function local_normal_at(plane::Plane, point::Vec3D)
    return vector3D(0.0, 1.0, 0.0)
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
