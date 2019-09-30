module CameraModule

export Camera, ray_for_pixel

using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
using Aether.Rays

using LinearAlgebra
using StaticArrays

mutable struct Camera
    hsize::Int64
    vsize::Int64
    field_of_view::Float64
    transform::SMatrix{4,4,Float64}
    half_width::Float64
    half_height::Float64
    pixel_size::Float64

    function Camera(hsize::Int64, vsize::Int64, field_of_view::Float64)
        half_view = tan(field_of_view / 2)
        aspect = hsize / vsize
        if aspect >= 1
            half_width = half_view
            half_height = half_view / aspect
        else
            half_width = half_view * aspect
            half_height = half_view
        end
        pixel_size = (half_width * 2) / hsize
        new(hsize, vsize, field_of_view, identity_matrix(Float64),
            half_width, half_height, pixel_size)
    end
end

# TODO: add inverse property to Camera and save inv(transform)
function ray_for_pixel(camera::Camera, px::Int64, py::Int64)
    # the offset from the edge of the canvas to the pixel's center
    xoffset = (px + 0.5) * camera.pixel_size
    yoffset = (py + 0.5) * camera.pixel_size
    # the untransformed coordinates of the pixel in world space.
    # (remember that the camera looks toward -z, so +x is to the *left*.)
    world_x = camera.half_width - xoffset
    world_y = camera.half_height - yoffset
    # using the camera matrix, transform the canvas point and the origin,
    # and then compute the ray's direction vector.
    # (remember that the canvas is at z=-1)
    pixel = inv(camera.transform) * point3D(world_x, world_y, -1.)
    origin = inv(camera.transform) * point3D(0., 0., 0.)
    direction = normalize(pixel - origin)
    return Ray(origin, direction)
end

end  # module
