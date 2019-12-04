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

mutable struct Cube <: GeometricObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    parent::Union{GroupType,Nothing}

    function Cube()
        new(
            identity_matrix(Float64),
            identity_matrix(Float64),
            default_material(),
            nothing,
        )
    end
end

function local_intersect(cube::Cube, ray::Ray)
    result = ()
    xtmin, xtmax = check_axis(ray.origin.x, ray.direction.x)
    ytmin, ytmax = check_axis(ray.origin.y, ray.direction.y)
    ztmin, ztmax = check_axis(ray.origin.z, ray.direction.z)

    tmin = max(xtmin, ytmin, ztmin)
    tmax = min(xtmax, ytmax, ztmax)
    if tmax >= tmin
        result = (Intersection(tmin, cube), Intersection(tmax, cube))
    end
    return result
end

function check_axis(origin::Float64, direction::Float64)
    tmin_numerator = (-1 - origin)
    tmax_numerator = (1 - origin)

    if abs(direction) >= ϵ
        tmin = tmin_numerator / direction
        tmax = tmax_numerator / direction
    else
        tmin = tmin_numerator * Inf
        tmax = tmax_numerator * Inf
    end

    if tmin > tmax
        tmin, tmax = tmax, tmin
    end
    return tmin, tmax
end

function local_normal_at(cube::Cube, point::Vec3D)
    abs_x = abs(point.x)
    abs_y = abs(point.y)
    abs_z = abs(point.z)

    maxc = max(abs_x, abs_y, abs_z)
    if maxc == abs_x
        return vector3D(point.x, 0.0, 0.0)
    elseif maxc == abs_y
        return vector3D(0.0, point.y, 0.0)
    end

    return vector3D(0.0, 0.0, point.z)
end
