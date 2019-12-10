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
    # floor
    floor_plane = Plane()
    floor_plane.material.pattern = CheckerPattern(
        ColorRGB(0.5, 0.5, 0.5),
        ColorRGB(0.75, 0.75, 0.75),
    )
    set_pattern_transform(
        floor_plane.material.pattern,
        rotation_y(0.3) * scaling(0.25, 0.25, 0.25),
    )
    floor_plane.material.ambient = 0.2
    floor_plane.material.diffuse = 0.9
    floor_plane.material.specular = 0.0

    # cylinders
    cylinder_1 = Cylinder()
    cylinder_1.minimum = 0.0
    cylinder_1.maximum = 0.75
    cylinder_1.closed = true
    set_transform(
        cylinder_1,
        translation(-1.0, 0.0, 1.0) * scaling(0.5, 1.0, 0.5),
    )
    cylinder_1.material.color = ColorRGB(0.0, 0.0, 0.6)
    cylinder_1.material.diffuse = 0.1
    cylinder_1.material.specular = 0.9
    cylinder_1.material.shininess = 300
    cylinder_1.material.reflective = 0.9

    # concentric cylinders
    cylinder_2 = Cylinder()
    cylinder_2.minimum = 0.0
    cylinder_2.maximum = 0.2
    cylinder_2.closed = false
    set_transform(
        cylinder_2,
        translation(1.0, 0.0, 0.0) * scaling(0.8, 1.0, 0.8),
    )
    cylinder_2.material.color = ColorRGB(1.0, 1.0, 0.3)
    cylinder_2.material.ambient = 0.1
    cylinder_2.material.diffuse = 0.8
    cylinder_2.material.specular = 0.9
    cylinder_2.material.shininess = 300

    cylinder_3 = Cylinder()
    cylinder_3.minimum = 0.0
    cylinder_3.maximum = 0.3
    cylinder_3.closed = false
    set_transform(
        cylinder_3,
        translation(1.0, 0.0, 0.0) * scaling(0.6, 1.0, 0.6),
    )
    cylinder_3.material.color = ColorRGB(1.0, 0.9, 0.4)
    cylinder_3.material.ambient = 0.1
    cylinder_3.material.diffuse = 0.8
    cylinder_3.material.specular = 0.9
    cylinder_3.material.shininess = 300

    cylinder_4 = Cylinder()
    cylinder_4.minimum = 0.0
    cylinder_4.maximum = 0.4
    cylinder_4.closed = false
    set_transform(
        cylinder_4,
        translation(1.0, 0.0, 0.0) * scaling(0.4, 1.0, 0.4),
    )
    cylinder_4.material.color = ColorRGB(1.0, 0.8, 0.5)
    cylinder_4.material.ambient = 0.1
    cylinder_4.material.diffuse = 0.8
    cylinder_4.material.specular = 0.9
    cylinder_4.material.shininess = 300

    cylinder_5 = Cylinder()
    cylinder_5.minimum = 0.0
    cylinder_5.maximum = 0.5
    cylinder_5.closed = false
    set_transform(
        cylinder_5,
        translation(1.0, 0.0, 0.0) * scaling(0.2, 1.0, 0.2),
    )
    cylinder_5.material.color = ColorRGB(1.0, 0.7, 0.6)
    cylinder_5.material.ambient = 0.1
    cylinder_5.material.diffuse = 0.8
    cylinder_5.material.specular = 0.9
    cylinder_5.material.shininess = 300

    # decorative cylinders
    dec1 = Cylinder()
    dec1.minimum = 0.0
    dec1.maximum = 0.3
    dec1.closed = true
    set_transform(
        dec1,
        translation(0.0, 0.0, -0.75) * scaling(0.05, 1.0, 0.05),
    )
    dec1.material.color = ColorRGB(1.0, 0.0, 0.0)
    dec1.material.ambient = 0.1
    dec1.material.diffuse = 0.9
    dec1.material.specular = 0.9
    dec1.material.shininess = 300

    dec2 = Cylinder()
    dec2.minimum = 0.0
    dec2.maximum = 0.3
    dec2.closed = true
    set_transform(
        dec2,
        translation(0.0, 0.0, -2.25) * rotation_y(-0.15) *
        translation(0.0, 0.0, 1.5) * scaling(0.05, 1.0, 0.05),
    )
    dec2.material.color = ColorRGB(1.0, 1.0, 0.0)
    dec2.material.ambient = 0.1
    dec2.material.diffuse = 0.9
    dec2.material.specular = 0.9
    dec2.material.shininess = 300

    dec3 = Cylinder()
    dec3.minimum = 0.0
    dec3.maximum = 0.3
    dec3.closed = true
    set_transform(
        dec3,
        translation(0.0, 0.0, -2.25) * rotation_y(-0.3) *
        translation(0.0, 0.0, 1.5) * scaling(0.05, 1.0, 0.05),
    )
    dec3.material.color = ColorRGB(0., 1.0, 0.0)
    dec3.material.ambient = 0.1
    dec3.material.diffuse = 0.9
    dec3.material.specular = 0.9
    dec3.material.shininess = 300

    dec4 = Cylinder()
    dec4.minimum = 0.0
    dec4.maximum = 0.3
    dec4.closed = true
    set_transform(
        dec4,
        translation(0.0, 0.0, -2.25) * rotation_y(-0.45) *
        translation(0.0, 0.0, 1.5) * scaling(0.05, 1.0, 0.05),
    )
    dec4.material.color = ColorRGB(0., 1.0, 1.0)
    dec4.material.ambient = 0.1
    dec4.material.diffuse = 0.9
    dec4.material.specular = 0.9
    dec4.material.shininess = 300

    # glass_cylinder
    glass_cyl = Cylinder()
    glass_cyl.minimum = 0.0001
    glass_cyl.maximum = 0.5
    glass_cyl.closed = true
    set_transform(
        glass_cyl,
        translation(0.0, 0.0, -1.5) * scaling(0.33, 1.0, 0.33),
    )
    glass_cyl.material.color = ColorRGB(0.25, 0., 0.)
    glass_cyl.material.diffuse = 0.1
    glass_cyl.material.specular = 0.9
    glass_cyl.material.shininess = 300.
    glass_cyl.material.reflective = 0.9
    glass_cyl.material.transparency = 0.9
    glass_cyl.material.refractive_index = 1.5

    world = World()
    world.light = PointLight(point3D(1.0, 6.9, -4.9), ColorRGB(1.0, 1.0, 1.0))
    add_objects(
        world,
        floor_plane,
        cylinder_1,
        cylinder_2,
        cylinder_3,
        cylinder_4,
        cylinder_5,
        dec1,
        dec2,
        dec3,
        dec4,
        glass_cyl
    )
    camera = Camera(800, 400, 0.314)
    camera_set_transform(
        camera,
        view_transform(
            point3D(8.0, 3.5, -9.0),
            point3D(0.0, 0.3, 0.0),
            vector3D(0.0, 1.0, 0.0),
        ),
    )

    canvas = render_multithread(camera, world)
end

function show_scene()
    canvas = draw_world()
    show_image(canvas)
    save_image(canvas, "renders/cylinders_scene.png")
end
