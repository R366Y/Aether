using Aether.CanvasModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.MatrixTransformations
using Aether.Rays
using Aether.Spheres

using StaticArrays
using LinearAlgebra

function draw_sphere()
    ray_origin = point3D(0., 0., -5.)
    wall_z = 10.
    wall_size = 7.0

    canvas_pixels = 100
    pixel_size = wall_size / canvas_pixels
    half = wall_size / 2

    canvas = Canvas(canvas_pixels, canvas_pixels, ColorRGB())
    color = ColorRGB(1., 0., 0.)
    shape = default_sphere()

    for y in 1:canvas_pixels
        world_y = half - pixel_size * y
        for x in 1:canvas_pixels
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
    canvas = draw_sphere()
    show_image(canvas)
end
