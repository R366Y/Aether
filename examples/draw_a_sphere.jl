using Aether.CanvasModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.BaseGeometricType
using Aether.MatrixTransformations
using Aether.Rays
using Aether.Shapes

using StaticArrays
using LinearAlgebra

import Aether.BaseGeometricType: r_intersect, set_transform

function draw_sphere(matrix_transformation::SMatrix)
    ray_origin = point3D(0., 0., -5.)
    wall_z = 10.
    wall_size = 7.0

    canvas_pixels = 100
    pixel_size = wall_size / canvas_pixels
    half = wall_size / 2

    canvas = Canvas(canvas_pixels, canvas_pixels, ColorRGB())
    color = ColorRGB(1., 0., 0.)
    shape = default_sphere()
    set_transform(shape, matrix_transformation)

    for y = 1:canvas_pixels
        world_y = half - pixel_size * y
        for x = 1:canvas_pixels
            world_x = -half + pixel_size * x
            position = point3D(world_x, world_y, wall_z)
            r = Ray(ray_origin, normalize(position - ray_origin))
            xs = r_intersect(shape, r)
            if hit(xs) !== nothing
                write_pixel!(canvas, x, y, color)
            end
        end
    end
    return canvas
end

function show_sphere()
    canvas = draw_sphere(identity_matrix(Float64))
    show_image(canvas)
end

function show_scaled_sphere()
    canvas = draw_sphere(scaling(1., 0.5, 1.))
    show_image(canvas)
end

function show_shrinked_rotated_sphere()
    canvas = draw_sphere(rotation_z(pi / 4) * scaling(0.5, 1., 1.))
    show_image(canvas)
end

function show_shrinked_skewed_sphere()
    canvas = draw_sphere(shearing(1., 0., 0., 0., 0., 0.) *
                         scaling(0.5, 1., 1.))
    show_image(canvas)
end
