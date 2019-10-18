import Aether: ϵ
import Aether.BaseGeometricType: GeometricObject, local_intersect,
                                 local_normal_at
import Aether.HomogeneousCoordinates: point3D, vector3D, Vec3D
import Aether.Intersections: Intersection
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

mutable struct Cylinder <: GeometricObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material

    function Cylinder()
        new(identity_matrix(Float64), identity_matrix(Float64),
        default_material())
    end
end

function local_intersect(cylinder::Cylinder, ray::Ray)
    a = ray.direction.x^2 + ray.direction.z^2

    result = Intersection[]
    # ray is parallel to y axis
    if abs(a) < ϵ
        return result
    end

    b = 2 * ray.origin.x * ray.direction.x +
        2 * ray.origin.z * ray.direction.z
    c = ray.origin.x^2 + ray.origin.z^2 - 1

    disc = b^2 - 4*a*c
    #ray does not intersect the cylinder
    if disc < 0.
        return result
    end
    sqrt_disc = √disc
    den = 2*a
    t0 = (-b - sqrt_disc)/den
    t1 = (-b + sqrt_disc)/den
    push!(result, Intersection(t0, cylinder), Intersection(t1, cylinder))
    return result
end
