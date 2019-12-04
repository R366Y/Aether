module CSolidGeometry

export CSG, csg

import Aether.BaseGeometricType: GeometricObject, GroupType
import Aether.MatrixTransformations: Matrix4x4, identity_matrix

mutable struct CSG <: GroupType 
    transform::Matrix4x4
    inverse::Matrix4x4
    parent::Union{GroupType,Nothing}
    operation::String
    left::GeometricObject
    right::GeometricObject
end

function CSG(operation::String, s1::GeometricObject, s2::GeometricObject)
    c = CSG(identity_matrix(Float64), 
            identity_matrix(Float64),
            nothing,
            operation, 
            s1, 
            s2)
    s1.parent = c
    s2.parent = c
    return c
end

end