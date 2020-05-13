import Aether.BaseGeometricType: GeometricObject, local_intersect, GroupType
import Aether.HomogeneousCoordinates: point3D, vector3D
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

mutable struct TestShape <: GeometricObject
    transform::Matrix4x4
    inverse::Matrix4x4
    material::Material
    parent::Union{GroupType,Nothing}
    saved_ray::Union{Ray, Nothing}
    shadow::Bool

    function TestShape()
        new(
            identity_matrix(),
            identity_matrix(),
            default_material(),
            nothing,
            nothing,
            true
        )
    end
end

function local_intersect(shape::TestShape, ray::Ray)
    shape.saved_ray = ray
    return ()
end
