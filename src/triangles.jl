import Aether: ϵ
import Aether.BaseGeometricType: GeometricObject, Group, Intersection
import Aether.HomogeneousCoordinates: point3D,
                                      vector3D,
                                      Vecf64,
                                      normalize,
                                      cross,
                                      dot
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

abstract type TriangleObject <: GeometricObject end

mutable struct Triangle <: TriangleObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    p1::Vecf64
    p2::Vecf64
    p3::Vecf64
    e1::Vecf64
    e2::Vecf64
    normal::Vecf64
    parent::Union{Ref{Group},Nothing}

    function Triangle(p1::Vecf64, p2::Vecf64, p3::Vecf64)
        e1 = p2 - p1
        e2 = p3 - p1
        normal = normalize(cross(e2, e1))
        new(identity_matrix(Float64),
            identity_matrix(Float64),
            default_material(),
            p1, p2, p3,
            e1, e2, 
            normal, nothing)
    end
end

mutable struct SmoothTriangle <: TriangleObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    p1::Vecf64
    p2::Vecf64
    p3::Vecf64
    n1::Vecf64
    n2::Vecf64
    n3::Vecf64
    e1::Vecf64
    e2::Vecf64
    normal::Vecf64
    parent::Union{Ref{Group},Nothing}

    function SmoothTriangle(p1::Vecf64, p2::Vecf64, p3::Vecf64,
                      n1::Vecf64, n2::Vecf64, n3::Vecf64)
        e1 = p2 - p1
        e2 = p3 - p1
        normal = normalize(cross(e2, e1))
        new(identity_matrix(Float64),
            identity_matrix(Float64),
            default_material(),
            p1, p2, p3, 
            n1, n2, n3,
            e1, e2, 
            normal, nothing)
    end
end

function local_intersect(triangle::Triangle, ray::Ray)
    res = triangle_intersect(triangle, ray) 
    if !isempty(res)
        t, u, v = res
        return (Intersection(t, triangle),)
    end
    return res
end

function local_intersect(triangle::SmoothTriangle, ray::Ray)
    res = triangle_intersect(triangle, ray) 
    if !isempty(res)
        t, u, v = res
        return (Intersection(t, triangle, u, v),)
    end
    return res
end

function triangle_intersect(triangle::TriangleObject, ray::Ray)
    dir_cross_e2 = cross(ray.direction, triangle.e2)
    det = dot(triangle.e1, dir_cross_e2)
    if abs(det) < ϵ
        return ()
    end
    f = 1.0 / det
    p1_to_origin = ray.origin - triangle.p1
    u = f * dot(p1_to_origin, dir_cross_e2)
    if u < 0.0 || u > 1.0
        return ()
    end
    origin_cross_e1 = cross(p1_to_origin, triangle.e1)
    v = f * dot(ray.direction, origin_cross_e1)
    if v < 0 || (u + v) > 1
        return ()
    end

    t = f * dot(triangle.e2, origin_cross_e1)
    return t, u, v
end

function local_normal_at(triangle::Triangle, point::Vec3D)
    return triangle.normal
end
