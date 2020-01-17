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
import Aether.Utils: push_tuple

mutable struct Cylinder <: GeometricObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    minimum::Float64
    maximum::Float64
    closed::Bool
    parent::Union{GroupType,Nothing}
    shadow::Bool

    function Cylinder()
        new(
            identity_matrix(Float64),
            identity_matrix(Float64),
            default_material(),
            -Inf,
            Inf,
            false,
            nothing,
            true
        )
    end
end

function local_intersect(cylinder::Cylinder, ray::Ray)
    i0 = nothing
    i1 = nothing
    result = ()

    a = ray.direction.x^2 + ray.direction.z^2
    # ray is parallel to y axis
    if abs(a) >= ϵ
        b = 2 * ray.origin.x * ray.direction.x +
            2 * ray.origin.z * ray.direction.z
        c = ray.origin.x^2 + ray.origin.z^2 - 1

        disc = b^2 - 4 * a * c
        #ray does not intersect the cylinder
        if disc < 0.0
            return result
        end
        sqrt_disc = √disc
        den = 2 * a
        t0 = (-b - sqrt_disc) / den
        t1 = (-b + sqrt_disc) / den

        y0 = ray.origin.y + t0 * ray.direction.y
        if cylinder.minimum < y0 && y0 < cylinder.maximum
            i0 = Intersection(t0, cylinder)
        end

        y1 = ray.origin.y + t1 * ray.direction.y
        if cylinder.minimum < y1 && y1 < cylinder.maximum
            i1 = Intersection(t1, cylinder)
        end
    end

    ci0, ci1 = intersect_caps(cylinder, ray)
    result = push_tuple(i0, i1, ci0, ci1)
    return result
end

function local_normal_at(cylinder::Cylinder, point::Vec3D)
    # compute the normal vector on a cylinder's end cap
    dist = point.x^2 + point.z^2
    if dist < 1 && point.y >= cylinder.maximum - ϵ
        return vector3D(0.0, 1.0, 0.0)
    elseif dist < 1 && point.y <= cylinder.minimum + ϵ
        return vector3D(0.0, -1.0, 0.0)
    else
        # normal vector on a cylinder
        return vector3D(point.x, 0.0, point.z)
    end
end

function intersect_caps(cyl::Cylinder, ray::Ray)
    ci0 = nothing
    ci1 = nothing
    # caps only matter if the cylinder is closed, and might possibly be
    # intersected by the ray.
    if !cyl.closed || abs(ray.direction.y) < ϵ
        return ci0, ci1
    end

    # check for an intersection with the lower end cap by intersecting
    # the ray with the plane at y=cyl.minimum
    t = (cyl.minimum - ray.origin.y) / ray.direction.y
    if check_cap(ray, t)
        ci0 = Intersection(t, cyl)
    end
    # check for an intersection with the upper end cap by intersecting
    # the ray with the plane at y=cyl.maximum
    t = (cyl.maximum - ray.origin.y) / ray.direction.y
    if check_cap(ray, t)
        ci1 = Intersection(t, cyl)
    end
    return ci0, ci1
end

# checks to see if the intersection at `t` is within a radius
# of 1 (the radius of your cylinders) from the y axis.
function check_cap(ray::Ray, t::Float64)
    x = ray.origin.x + t * ray.direction.x
    z = ray.origin.z + t * ray.direction.z
    return (x^2 + z^2) <= 1
end
