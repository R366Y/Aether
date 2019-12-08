module CSolidGeometry

export CSG, csg_union_op, csg_intersect_op, csg_difference_op
export intersection_allowed, filter_intersections

using Aether
import Aether.BaseGeometricType: GeometricObject, GroupType, Group, Intersection, r_intersect, local_intersect
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

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
    # this field contains bounding box for the group but it cannot be declared
    # as BoundingBox because that is defined after groups, cannot have cyclic module
    # dependencies in Julia :(
    aabb
end

function CSG(operation::String, s1::GeometricObject, s2::GeometricObject)
    c = CSG(identity_matrix(Float64), identity_matrix(Float64),
            nothing, operation, s1, s2, nothing)
    s1.parent = c
    s2.parent = c
    return c
end

function intersection_allowed(operation::String, lhit::Bool, inl::Bool, inr::Bool)
    if operation == csg_union_op
        return (lhit && !inr) || (!lhit && !inl)
    elseif operation == csg_intersect_op
        return (lhit && inr) || (!lhit && inl)
    elseif operation == csg_difference_op
        return (lhit && !inr) || (!lhit && inl)
    end

    return false
end

function filter_intersections(csg::CSG, xs::Array)
    # begin outside of both children
    inl = false
    inr = false

    # prepare a list to receive the filtered intersections
    result = Intersection[]

    for i in xs
        # if i.gobject is part of the "left" child, then lhit is true
        lhit = csg_includes_gobject(csg.left, i.gobject)
        if intersection_allowed(csg.operation, lhit, inl, inr)
            push!(result, i)
        end
        # depending on which object was hit, toggle either inl or inr
        if lhit
            inl = !inl
        else
            inr = !inr
        end
    end
    return result
end

function csg_includes_gobject(csg_object::GeometricObject, gobject::GeometricObject)
    csg_object_type = typeof(csg_object)
    if csg_object_type == Group
        for o in csg_object.shapes
            if csg_includes_gobject(o, gobject)
                return true
            end
        end
    elseif csg_object_type == CSG
        return gobject == csg_object.right || gobject == csg_object.left
    else
        return gobject == csg_object
    end
    return false
end

function local_intersect(csg::CSG, ray::Ray)
    if isnothing(csg.aabb)
        csg.aabb = bounds_of(csg)
    end
    result = ()
    if aabb_intersect(csg.aabb, ray)
        leftxs = r_intersect(csg.left, ray)
        rightxs = r_intersect(csg.right, ray)
        xs = vcat(leftxs..., rightxs...)
        if !isempty(xs)
            sort!(xs, by = i -> i.t)
            filtered_intersections = filter_intersections(csg, xs)
            return (filtered_intersections...,)
        end
    end
    return result
end

end
