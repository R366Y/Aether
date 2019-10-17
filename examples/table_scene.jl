using Aether.CameraModule
using Aether.CanvasModule
using Aether.ColorsModule
using Aether.Cubes
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Patterns
using Aether.Planes
using Aether.Spheres
using Aether.WorldModule

import Aether.BaseGeometricType: set_transform

function draw_world()
    # Floor/ceiling
    ceiling = Cube()
    set_transform(ceiling, scaling(20., 7., 20.) * translation(0., 1., 0.))
    ceiling.material.pattern = CheckerPattern(black, ColorRGB(0.25, 0.25, 0.25))
    set_pattern_transform(ceiling.material.pattern, scaling(0.07, 0.07, 0.07))
    ceiling.material.ambient = 0.25
    ceiling.material.diffuse = 0.7
    ceiling.material.specular = 0.9
    ceiling.material.shininess = 300.
    ceiling.material.reflective = 0.1

    walls = Cube()
    set_transform(walls, scaling(10.,10.,10.))
    walls.material.pattern = CheckerPattern(ColorRGB(0.4863, 0.3765, 0.2941),
                             ColorRGB(0.3725, 0.2902, 0.2275))
    set_pattern_transform(walls.material.pattern, scaling(0.05, 20., 0.05))
    walls.material.ambient = 0.1
    walls.material.diffuse = 0.7
    walls.material.specular = 0.9
    walls.material.shininess = 300.
    walls.material.reflective = 0.1

    # table
    table_top = Cube()
    set_transform(table_top, translation(0., 3.1, 0.) * scaling(3., 0.1, 2.))
    table_top.material.pattern = StripePattern(ColorRGB(0.5529, 0.4235, 0.3255),
                                 ColorRGB(0.6588, 0.5098, 0.4000))
    set_pattern_transform(table_top.material.pattern, scaling(0.05, 0.05, 0.05) *
                          rotation_y(0.1))
    table_top.material.ambient = 0.1
    table_top.material.diffuse = 0.7
    table_top.material.specular = 0.9
    table_top.material.shininess = 300
    table_top.material.reflective = 0.2

    leg1 = Cube()
    set_transform(leg1, translation(2.7, 1.5, -1.7) * scaling(0.1, 1.5, 0.1))
    leg1.material.color = ColorRGB(0.5529, 0.4235, 0.3255)
    leg1.material.ambient = 0.2
    leg1.material.diffuse = 0.7

    leg2 = Cube()
    set_transform(leg2, translation(2.7, 1.5, 1.7) * scaling(0.1, 1.5, 0.1))
    leg2.material.color = ColorRGB(0.5529, 0.4235, 0.3255)
    leg2.material.ambient = 0.2
    leg2.material.diffuse = 0.7

    leg3 = Cube()
    set_transform(leg3, translation(-2.7, 1.5, -1.7) * scaling(0.1, 1.5, 0.1))
    leg3.material.color = ColorRGB(0.5529, 0.4235, 0.3255)
    leg3.material.ambient = 0.2
    leg3.material.diffuse = 0.7

    leg4 = Cube()
    set_transform(leg4, translation(-2.7, 1.5, 1.7) * scaling(0.1, 1.5, 0.1))
    leg4.material.color = ColorRGB(0.5529, 0.4235, 0.3255)
    leg4.material.ambient = 0.2
    leg4.material.diffuse = 0.7

    # objects on the table
    glass_cube = Cube()
    set_transform(glass_cube, translation(0., 3.45001, 0.) * rotation_y(0.2) *
                  scaling(0.25, 0.25, 0.25))
    glass_cube.material.color = ColorRGB(1., 1., 0.8)
    glass_cube.material.ambient = 0.
    glass_cube.material.diffuse = 0.3
    glass_cube.material.specular = 0.9
    glass_cube.material.shininess = 300.
    glass_cube.material.reflective = 0.7
    glass_cube.material.transparency = 0.7
    glass_cube.material.refractive_index = 1.5

    little_cube1 = Cube()
    set_transform(little_cube1, translation(1., 3.35, -0.9) * rotation_y(-0.4) *
                  scaling(0.15, 0.15, 0.15))
    little_cube1.material.color = ColorRGB(1., 0.5, 0.5)
    little_cube1.material.reflective = 0.6
    little_cube1.material.diffuse = 0.4

    little_cube2 = Cube()
    set_transform(little_cube2, translation(-1.5, 3.27, 0.3) * rotation_y(0.4) *
                  scaling(0.15, 0.07, 0.15))
    little_cube2.material.color = ColorRGB(1., 1., 0.5)

    little_cube3 = Cube()
    set_transform(little_cube3, translation(0., 3.25, 1.) * rotation_y(0.4) *
                  scaling(0.2, 0.05, 0.05))
    little_cube3.material.color = ColorRGB(0.5, 1., 0.5)

    little_cube4 = Cube()
    set_transform(little_cube4, translation(-0.6, 3.4, -1.) * rotation_y(0.8) *
                  scaling(0.05, 0.2, 0.05))
    little_cube4.material.color = ColorRGB(0.5, 0.5, 1.)

    little_cube5 = Cube()
    set_transform(little_cube5, translation(2., 3.4, 1.) * rotation_y(0.8) *
                  scaling(0.05, 0.2, 0.05))
    little_cube5.material.color = ColorRGB(0.5, 1., 1.)

    # frames
    frame1 = Cube()
    set_transform(frame1, translation(-10., 4., 1.) * scaling(0.05, 1., 1.))
    frame1.material.color = ColorRGB(0.7098, 0.2471, 0.2196)
    frame1.material.diffuse = 0.6

    frame2 = Cube()
    set_transform(frame2, translation(-10., 3.4, 2.7) * scaling(0.05, 0.4, 0.4))
    frame2.material.color = ColorRGB(0.2667, 0.2706, 0.6902)
    frame2.material.diffuse = 0.6

    frame3 = Cube()
    set_transform(frame3, translation(-10., 4.6, 2.7) * scaling(0.05, 0.4, 0.4))
    frame3.material.color = ColorRGB(0.3098, 0.5961, 0.3098)
    frame3.material.diffuse = 0.6

    mirror_frame = Cube()
    set_transform(mirror_frame, translation(-2., 3.5, 9.95) *
                  scaling(5., 1.5, 0.05))
    mirror_frame.material.color = ColorRGB(0.3882, 0.2627, 0.1882)
    mirror_frame.material.diffuse = 0.7

    mirror = Cube()
    set_transform(mirror, translation(-2., 3.5, 9.95) *
                  scaling(4.8, 1.4, 0.06))
    mirror.material.color = black
    mirror.material.diffuse = 0.
    mirror.material.ambient = 0.
    mirror.material.specular = 1.
    mirror.material.shininess = 300.
    mirror.material.reflective = 1.

    world = World()
    world.light = PointLight(point3D(0., 6.9, -5.) , ColorRGB(1., 1., 0.9))
    add_objects(world, ceiling, walls, table_top, leg1, leg2, leg3, leg4,
                glass_cube, little_cube1, little_cube2, little_cube3,
                little_cube4, little_cube5, frame1, frame2, frame3, mirror_frame,
                mirror)
    camera = Camera(800, 400, 0.785)
    camera_set_transform(camera, view_transform(point3D(8., 6., -8.),
                                                point3D(0., 3., 0.),
                                                vector3D(0., 1., 0.)))

    canvas = render(camera, world)
end

function show_scene()
    canvas = draw_world()
    show_image(canvas)
    save_image(canvas, "renders/table_scene.png")
end
