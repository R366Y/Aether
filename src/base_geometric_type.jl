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

"""
  GeometricObject

Base type for all the shapes (box, plane, sphere, triangle etc.)
"""
abstract type GeometricObject end

"""
    set_transform(shape::GeometricObject, matrix::Matrix4x4)

Set transform and inverse matrixes for a shape of type `GeometricObject`.
The shape MUST have the two fields `transform` and `inverse`.
"""
function set_transform(shape::T, matrix::Matrix4x4) where {T<:GeometricObject}
    shape.transform = matrix
    shape.inverse = inv(matrix)
end

"""
    r_intersect(shape::GeometricObject, ray::Ray)

Calculate intersections between a ray and a shape.
"""
function r_intersect(shape::T, ray::Ray) where {T<:GeometricObject}
    local_ray = transform(ray, shape.inverse)
    return local_intersect(shape, local_ray)
end

"""
    local_intersect(shape::GeometricObject, ray::Ray)

Calculate the intersection bewteen a ray and a shape after the ray has been transformed
to local coordinates. Standard implementation returns an empty `Array`.
This function MUST be implemented for every shape.
"""
function local_intersect(shape::T, ray::Ray) where {T<:GeometricObject}
    return []
end

"""
    normal_at(shape::GeometricObject, world_point::Vec3D, u::Union{Float64, Nothing} = nothing, v::Union{Float64, Nothing} = nothing)

Calculate the normal in world coordinates at a point on the shape.
"""
function normal_at(shape::T, world_point::Vec3D, 
                   u::Union{Float64, Nothing} = nothing, 
                   v::Union{Float64, Nothing} = nothing) where {T<:GeometricObject}
    local_point = world_to_object(shape, world_point)
    if !isnothing(u) && !isnothing(v)
        local_normal = local_normal_at(shape, local_point, u, v)
    else
        local_normal = local_normal_at(shape, local_point)
    end
    return normal_to_world(shape, local_normal)
end

"""
    local_normal_at(shape::GeometricObject, point::Vec3D)

Calculate the normal in local coordinates at a point on the shape.
This function MUST be implemented for every shape.
"""
function local_normal_at(shape::T, point::Vec3D) where {T<:GeometricObject}
    return vector3D(point.x, point.y, point.z)
end

"""
    local_normal_at(shape::GeometricObject, point::Vec3D, u::Float64, v::Float64)

Calculate the normal in local coordinates at a point on the shape.
This function is only meant to be used by smooth triangles, u/v are used for normal interpolation.
"""
function local_normal_at(shape::T, point::Vec3D, u::Float64, v::Float64) where {T<:GeometricObject}
    return vector3D(point.x, point.y, point.z)
end

"""
    get_parent_group(shape::GeometricObject)

Return the parent `Group` for a shape if the shape is a part of a group.
Otherwise returns `nothing`.
Shape MUST have a field called 'parent' that can contain the reference to a 'Group' instance.
"""
function get_parent_group(shape::T) where {T<:GeometricObject}
    result = nothing
    if !isnothing(shape.parent)
        result = shape.parent[]
    end
    return result
end

"""
    world_to_object(shape::GeometricObject, point::Vec3D)

Transform a point from world coordinates to local coordinates relative to the given shape. 
"""
function world_to_object(shape::T, point::Vec3D) where {T<:GeometricObject}
    if !isnothing(get_parent_group(shape))
        point = world_to_object(get_parent_group(shape), point)
    end
    return shape.inverse * point
end

"""
    normal_to_world(shape::GeometricObject, normal::Vec3D)

Transform a normal from local coordinates to world coordinates. Normal is also normalized.
"""
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
