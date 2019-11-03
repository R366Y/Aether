import Aether.BaseGeometricType: GeometricObject, local_intersect
import Aether.HomogeneousCoordinates: point3D, vector3D
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

mutable struct TestShape <: GeometricObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    parent::Union{Ptr, Nothing}
    saved_ray::Ray

    function TestShape()
        new(identity_matrix(Float64), identity_matrix(Float64),
            default_material(), nothing,
            Ray(point3D(0.,0.,0.), vector3D(0., 1., 0.)))
    end
end

function local_intersect(shape::TestShape, ray::Ray)
    shape.saved_ray = ray
    return ()
end
