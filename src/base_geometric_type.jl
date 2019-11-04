module BaseGeometricType

export GeometricObject,
       Group,
       Intersection,
       add_child,
       set_transform,
       r_intersect,
       local_intersect,
       normal_at,
       local_normal_at,
       world_to_object,
       get_parent_group,
       normal_to_world,
       hit

import Aether.HomogeneousCoordinates: point3D, vector3D, Vec3D, normalize
import Aether.MatrixTransformations: Matrix4x4
import Aether.Rays: Ray, transform

abstract type GeometricObject end

function set_transform(shape::T, matrix::Matrix4x4) where {T<:GeometricObject}
    shape.transform = matrix
    shape.inverse = inv(matrix)
end

function r_intersect(shape::T, ray::Ray) where {T<:GeometricObject}
    local_ray = transform(ray, shape.inverse)
    return local_intersect(shape, local_ray)
end

function local_intersect(shape::T, ray::Ray) where {T<:GeometricObject}
    return []
end

function normal_at(shape::T, world_point::Vec3D) where {T<:GeometricObject}
    local_point = world_to_object(shape, world_point)
    local_normal = local_normal_at(shape, local_point)
    return normal_to_world(shape, local_normal)
end

function local_normal_at(shape::T, point::Vec3D) where {T<:GeometricObject}
    return vector3D(point.x, point.y, point.z)
end

function get_parent_group(shape::T) where {T<:GeometricObject}
    result = nothing
    if !isnothing(shape.parent)
        result = unsafe_pointer_to_objref(shape.parent)
    end
    return result
end

function world_to_object(shape::T, point::Vec3D) where {T<:GeometricObject}
    if !isnothing(get_parent_group(shape))
        point = world_to_object(get_parent_group(shape), point)
    end
    return shape.inverse * point
end

function normal_to_world(shape::T, normal::Vec3D) where {T<:GeometricObject}
    normal = transpose(shape.inverse) * normal
    normal.w = 0.0
    normal = normalize(normal)
    if !isnothing(get_parent_group(shape))
        normal = normal_to_world(get_parent_group(shape), normal)
    end
    return normal
end

include("intersections.jl")
include("groups.jl")
end
