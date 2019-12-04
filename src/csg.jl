module CSolidGeometry

export CSG, csg_union_op, csg_intersect_op, csg_difference_op

import Aether.BaseGeometricType: GeometricObject, GroupType
import Aether.MatrixTransformations: Matrix4x4, identity_matrix

const csg_union_op = "union"
const csg_intersect_op = "intersect"
const csg_difference_op = "difference"

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

function intersection_allowed(operation::String, lhit::Bool, inl::Bool, inr::Bool)
    if operation == csg_union_op
        return (lhit && !inr) || (!lhit && !inl)
    end

    return false
end

end