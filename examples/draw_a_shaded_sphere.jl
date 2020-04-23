using Aether.CanvasModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.BaseGeometricType
using Aether.Materials
using Aether.Lights
using Aether.Shaders
using Aether.MatrixTransformations
using Aether.Rays
using Aether.Shapes

using StaticArrays
using LinearAlgebra

import Aether.BaseGeometricType: r_intersect, set_transform, normal_at

function draw_sphere(matrix_transformation::SMatrix = identity_matrix())
    ray_origin = point3D(0., 0., -5.)
    wall_z = 10.
    wall_size = 7.0

    canvas_pixels = 100
    pixel_size = wall_size / canvas_pixels
    half = wall_size / 2

    canvas = Canvas(canvas_pixels, canvas_pixels, ColorRGB())
    shape = default_sphere()
    set_transform(shape, matrix_transformation)
    shape.material = default_material()
    shape.material.color = ColorRGB(1., 0.2, 1.)

    light_position = point3D(-10., 10., -10.)
    light_color = ColorRGB(1.,1.,1.)
    light = PointLight(light_position, light_color)

    for y = 1:canvas_pixels
        world_y = half - pixel_size * y
        for x = 1:canvas_pixels
            world_x = -half + pixel_size * x
            position = point3D(world_x, world_y, wall_z)
            r = Ray(ray_origin, normalize(position - ray_origin))
            xs = r_intersect(shape, r)
            h = hit(xs)
            if h !== nothing
                point = positionr(r, h.t)
                normal = normal_at(h.gobject, point)
                eye = -r.direction
                color = lighting(h.gobject.material,h.gobject, light, point, eye, normal, 1.0)
                write_pixel!(canvas, x, y, color)
            end
        end
    end
    return canvas
end

function show_sphere()
    canvas = draw_sphere(identity_matrix())
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
