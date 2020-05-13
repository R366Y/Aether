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

    cone = Cone()
    cone.minimum = -1
    cone.maximum = 0.0
    cone.closed = false
    set_transform(
        cone,
        translation(0.0, 1.0, 1.0) * scaling(0.8, 1.0, 0.8),
    )
    cone.material.color = ColorRGB(1.0, 1.0, 0.3)
    cone.material.ambient = 0.1
    cone.material.diffuse = 0.8
    cone.material.specular = 0.9
    cone.material.shininess = 300

    glass_cone= Cone()
    glass_cone.minimum = 0.0
    glass_cone.maximum = 0.5
    glass_cone.closed = true
    set_transform(
        glass_cone,
        translation(0.0, 0.0, -1.5) * scaling(0.9, 1.0, 0.9),
    )
    glass_cone.material.color = ColorRGB(0.1, 0.1, 0.1)
    #cone.material.ambient = 0.1
    glass_cone.material.diffuse = 0.2
    glass_cone.material.specular = 0.9
    glass_cone.material.shininess = 300.
    glass_cone.material.reflective = 0.9

    world = World()
    l1 = PointLight(point3D(10.0, 6.9, -4.9), ColorRGB(1.0, 1.0, 1.0))
    l2 = PointLight(point3D(10.0, 3.9, 1.0), ColorRGB(1.0, 1.0, 1.0))
    add_lights!(world,l2, l1)
    add_objects(
        world,
        floor_plane,
        cone,
        glass_cone
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
    file_path = save_image(canvas, "renders/cone_scene.png")
    show_image_with_default_reader(joinpath("renders", "cone_scene.png"))
end
