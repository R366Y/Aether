module BaseGeometricType

export GeometricObject, set_transform, r_intersect, local_intersect,
       normal_at, local_normal_at

import Aether.HomogeneousCoordinates: point3D, vector3D, Vec3D, normalize
import Aether.MatrixTransformations: Matrix4x4
import Aether.Rays: Ray, transform

abstract type GeometricObject end

function set_transform(shape::T, matrix::Matrix4x4) where T <:GeometricObject
    shape.transform = matrix
    shape.inverse = inv(matrix)
end

function r_intersect(shape::T, ray::Ray) where T <:GeometricObject
    local_ray = transform(ray, shape.inverse)
    return local_intersect(shape, local_ray)
end

function local_intersect(shape::T, ray::Ray) where T <:GeometricObject
    return []
end

function normal_at(shape::T, point::Vec3D) where T <:GeometricObject
    local_point = shape.inverse * point
    local_normal = local_normal_at(shape, local_point)
    world_normal = transpose(shape.inverse) * local_normal
    world_normal.w = 0.
    return normalize(world_normal)
end

function local_normal_at(shape::T, point::Vec3D) where T <:GeometricObject
    return vector3D(point.x, point.y, point.z)
end

end
