using Aether.CameraModule
using Aether.CanvasModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Patterns
using Aether.Renders
using Aether.Shapes
using Aether.WorldModule

import Aether.BaseGeometricType: set_transform

function draw_world()
    wall_material = default_material()
    wall_material.pattern = StripePattern(ColorRGB(0.45, 0.45, 0.45),
                                          ColorRGB(0.55, 0.55, 0.55))
    set_pattern_transform(wall_material.pattern,
                          rotation_y(1.5708) * scaling(0.25, 0.25, 0.25) )
    wall_material.ambient = 0.
    wall_material.diffuse = 0.4
    wall_material.specular = 0.
    wall_material.reflective = 0.3

    checkered_floor = Plane()
    set_transform(checkered_floor, rotation_y(0.31415))
    checkered_floor.material.pattern = CheckerPattern(
                                       ColorRGB(0.35, 0.35, 0.35),
                                       ColorRGB(0.65, 0.65, 0.65))
    checkered_floor.material.specular = 0.
    checkered_floor.material.reflective = 0.4

    ceiling = Plane()
    set_transform(ceiling, translation(0., 5., 0.))
    ceiling.material.color = ColorRGB(0.8, 0.8, 0.8)
    ceiling.material.ambient = 0.3
    ceiling.material.specular = 0.

    west_wall = Plane()
    set_transform(west_wall,translation(-5., 0., 0.) * rotation_z(1.5708) *rotation_y(1.5708))
    west_wall.material = wall_material

    east_wall = Plane()
    set_transform(east_wall,translation(5., 0., 0.) * rotation_z(1.5708) * rotation_y(1.5708))
    east_wall.material = wall_material

    north_wall = Plane()
    set_transform(north_wall,translation(0., 0., 5.) * rotation_x(1.5708))
    north_wall.material = wall_material

    south_wall = Plane()
    set_transform(south_wall,translation(0., 0., -5.) * rotation_x(1.5708))
    south_wall.material = wall_material

    bb1 = default_sphere()
    set_transform(bb1, translation(4.6, 0.4, 1.) * scaling(0.4, 0.4, 0.4))
    bb1.material.color = ColorRGB(0.8, 0.5, 0.3)
    bb1.material.shininess = 50.

    bb2 = default_sphere()
    set_transform(bb2, translation(4.7, 0.3, 0.4) * scaling(0.3, 0.3, 0.3))
    bb2.material.color = ColorRGB(0.9, 0.4, 0.5)
    bb2.material.shininess = 50.

    bb3 = default_sphere()
    set_transform(bb3, translation(-1., 0.5, 4.5) * scaling(0.5, 0.5, 0.5))
    bb3.material.color = ColorRGB(0.4, 0.9, 0.6)
    bb3.material.shininess = 50.

    bb4 = default_sphere()
    set_transform(bb4, translation(-1.7, 0.3, 4.7) * scaling(0.3, 0.3, 0.3))
    bb4.material.color = ColorRGB(0.4, 0.6, 0.9)
    bb4.material.shininess = 50.

    blue_glass_sphere = default_sphere()
    set_transform(blue_glass_sphere, translation(0.6, 0.7, -0.6) * scaling(0.7, 0.7, 0.7))
    blue_glass_sphere.material.color = ColorRGB(0., 0., 0.2)
    blue_glass_sphere.material.ambient = 0.
    blue_glass_sphere.material.diffuse = 0.4
    blue_glass_sphere.material.specular = 0.9
    blue_glass_sphere.material.shininess = 300
    blue_glass_sphere.material.reflective = 0.9
    blue_glass_sphere.material.transparency = 0.9
    blue_glass_sphere.material.refractive_index = 1.5

    green_glass_sphere = default_sphere()
    set_transform(green_glass_sphere, translation(-0.7, 0.5, -0.8) * scaling(0.5, 0.5, 0.5))
    green_glass_sphere.material.color = ColorRGB(0., 0.2, 0.)
    green_glass_sphere.material.ambient = 0.
    green_glass_sphere.material.diffuse = 0.4
    green_glass_sphere.material.specular = 0.9
    green_glass_sphere.material.shininess = 300
    green_glass_sphere.material.reflective = 0.9
    green_glass_sphere.material.transparency = 0.9
    green_glass_sphere.material.refractive_index = 1.5

    red_sphere = default_sphere()
    set_transform(red_sphere, translation(-0.6, 1., 0.6))
    red_sphere.material.color = ColorRGB(1., 0.3, 0.2)
    red_sphere.material.specular = 0.4
    red_sphere.material.shininess = 5.

    world = World()
    add_lights!(world, PointLight(point3D(-4.9, 4.9, -1.) , ColorRGB(1., 1., 1.)))
    add_objects(world, checkered_floor, ceiling, west_wall, east_wall,
                north_wall, south_wall, bb1, bb2, bb3, bb4, blue_glass_sphere,
                green_glass_sphere, red_sphere)
    camera = Camera(800, 400, 1.152)
    camera_set_transform(camera, view_transform(point3D(-2.6, 1.5, -3.9),
                                                point3D(-0.6, 1., -0.8),
                                                vector3D(0., 1., 0.)))

    canvas = render_multithread(camera, world)
    return canvas
end

function show_scene()
    canvas = draw_world()
    show_image(canvas)
    save_image(canvas, "renders/reflections_and_refractions.png")
end
