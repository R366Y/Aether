import Aether: ϵ
import Aether.BaseGeometricType: GeometricObject, Group, Intersection
import Aether.HomogeneousCoordinates: point3D,
                                      vector3D,
                                      Vecf64,
                                      normalize,
                                      cross,
                                      dot
import Aether.Rays: Ray

mutable struct Triangle <: GeometricObject
    p1::Vecf64
    p2::Vecf64
    p3::Vecf64
    e1::Vecf64
    e2::Vecf64
    normal::Vecf64
    parent::Union{Ptr{Group},Nothing}

    function Triangle(p1::Vecf64, p2::Vecf64, p3::Vecf64)
        e1 = p2 - p1
        e2 = p3 - p1
        normal = normalize(cross(e2, e1))
        new(p1, p2, p3, e1, e2, normal, nothing)
    end
end

function local_intersect(triangle::Triangle, ray::Ray)
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
    return (Intersection(t, triangle),)

end

function local_normal_at(triangle::Triangle, point::Vec3D)
    return triangle.normal
end
