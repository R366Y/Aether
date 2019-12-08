using Aether
import Aether.BaseGeometricType: GeometricObject,
                                 local_intersect,
                                 r_intersect,
                                 Intersection
import Aether.MatrixTransformations: Matrix4x4, identity_matrix
import Aether.Rays: Ray

abstract type GroupType <: GeometricObject end

mutable struct Group <: GroupType
    transform::Matrix4x4
    inverse::Matrix4x4
    parent::Union{GroupType,Nothing}
    shapes::Array{GeometricObject,1}
    # this field contains bounding box for the group but it cannot be declared
    # as BoundingBox because that is defined after groups, cannot have cyclic module
    # dependencies in Julia :(
    aabb

    function Group()
        new(
            identity_matrix(Float64),
            identity_matrix(Float64),
            nothing,
            GeometricObject[],
            nothing
        )
    end
end

function add_child!(group::Group, shape::GeometricObject)
    shape.parent = group
    push!(group.shapes, shape)
end

function group_of(shapes::Array{GeometricObject,1})
    g = Group()
    g.shapes = vcat(g.shapes, shapes)
    return g
end

function make_subgroup!(group::Group, shapes::Array{GeometricObject,1})
    g = group_of(shapes)
    add_child!(group, g)
end

function local_intersect(group::Group, ray::Ray)
    if isnothing(group.aabb)
        group.aabb = bounds_of(group)
    end
    result = ()
    if aabb_intersect(group.aabb, ray)
        intersections = Intersection[]
        for s in group.shapes
            xs = r_intersect(s, ray)
            if length(xs) != 0
                push!(intersections, xs...)
            end
        end
        if length(intersections) != 0
            sort!(intersections, by = i -> i.t)
        end
        result = (intersections...,)
    end
    return result
end
