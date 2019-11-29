import Aether: ϵ
import Aether.BaseGeometricType: GeometricObject,
                                 local_intersect,
                                 local_normal_at,
                                 Intersection,
                                 Group
import Aether.HomogeneousCoordinates: point3D, vector3D, Vec3D
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray
import Aether.Utils: push_tuple

mutable struct Cone <: GeometricObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    minimum::Float64
    maximum::Float64
    closed::Bool
    parent::Union{Ref{Group},Nothing}

    function Cone()
        new(
            identity_matrix(Float64),
            identity_matrix(Float64),
            default_material(),
            -Inf,
            Inf,
            false,
            nothing,
        )
    end
end

function local_intersect(cone::Cone, ray::Ray)
    result = ()
    i0 = nothing
    i1 = nothing

    origin = ray.origin
    direction = ray.direction
    a = direction.x^2 - direction.y^2 + direction.z^2
    b = 2 * origin.x * direction.x - 2 * origin.y * direction.y +
        2 * origin.z * direction.z
    c = origin.x^2 - origin.y^2 + origin.z^2

    if abs(a) > ϵ
        disc = b^2 - 4 * a * c
        #ray does not intersect the cylinder
        if disc < 0.0
            return result
        end
        sqrt_disc = √disc
        den = 2 * a
        t0 = (-b - sqrt_disc) / den
        t1 = (-b + sqrt_disc) / den

        y0 = origin.y + t0 * direction.y
        if cone.minimum < y0 && y0 < cone.maximum
            i0 = Intersection(t0, cone)
        end

        y1 = origin.y + t1 * direction.y
        if cone.minimum < y1 && y1 < cone.maximum
            i1 = Intersection(t1, cone)
        end
    elseif a == 0.0 && abs(b) > ϵ
        t = -c / 2b
        i0 = Intersection(t, cone)
    end

    ci0, ci1 = intersect_caps(cone, ray)
    result = push_tuple(i0, i1, ci0, ci1)
    return result
end

function local_normal_at(cone::Cone, point::Vec3D)
    # compute the normal vector on a cone's end cap
    dist = point.x^2 + point.z^2
    if dist < cone.maximum^2 && point.y >= cone.maximum - ϵ
        return vector3D(0.0, 1.0, 0.0)
    elseif dist < cone.minimum^2 && point.y <= cone.minimum + ϵ
        return vector3D(0.0, -1.0, 0.0)
    else
        # normal vector on a cone
        y = √(point.x^2 + point.z^2)
        if point.y > 0.0
            y = -y
        end
        return vector3D(point.x, y, point.z)
    end
end

function intersect_caps(cone::Cone, ray::Ray)
    ci0 = nothing
    ci1 = nothing
    # caps only matter if the cone is closed, and might possibly be
    # intersected by the ray.
    if !cone.closed || abs(ray.direction.y) < ϵ
        return ci0, ci1
    end

    # check for an intersection with the lower end cap by intersecting
    # the ray with the plane at y=cone.minimum
    t = (cone.minimum - ray.origin.y) / ray.direction.y
    if check_cap(ray, t, cone.minimum)
        ci0 = Intersection(t, cone)
    end
    # check for an intersection with the upper end cap by intersecting
    # the ray with the plane at y=cone.maximum
    t = (cone.maximum - ray.origin.y) / ray.direction.y
    if check_cap(ray, t, cone.maximum)
        ci1 = Intersection(t, cone)
    end
    return ci0, ci1
end

# checks to see if the intersection at `t` is within a radius
# from the y axis.
function check_cap(ray::Ray, t::Float64, radius::Float64)
    x = ray.origin.x + t * ray.direction.x
    z = ray.origin.z + t * ray.direction.z
    return (x^2 + z^2) <= radius^2
end
