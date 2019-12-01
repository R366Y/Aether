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
    parent::Union{Ref{Group},Nothing}
    shapes::Array{GeometricObject,1}

    function Group()
        new(
            identity_matrix(Float64),
            identity_matrix(Float64),
            nothing,
            GeometricObject[],
        )
    end
end

function add_child(group::Group, shape::GeometricObject)
    shape.parent = Ref(group)
    push!(group.shapes, shape)
end

function local_intersect(group::Group, ray::Ray)
    result = ()
    if aabb_intersect(bounds_of(group), ray)
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
