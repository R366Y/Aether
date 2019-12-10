using Aether
using Aether.AccelerationStructures
using Aether.BaseGeometricType
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

	obj_file = parse_obj_file("examples/resources/teapot_smooth.obj")
	teapot = obj_to_group(obj_file)
	divide!(teapot, 15)
    set_transform(teapot, scaling(0.145, 0.145, 0.145) * rotation_y(3/4 * pi) * rotation_x(-π/2) )

    world = World()
    l1 = PointLight(point3D(-2.0, 6.9, -4.9), ColorRGB(0.2, 0.2, 0.2))
    l2 = PointLight(point3D(2.0, 6.9, -4.9), ColorRGB(0.7, 0.7, 0.7))
    add_lights!(world, l1, l2)
    add_objects(world,teapot, floor_plane)

    camera = Camera(640, 480, 0.314)
    camera_set_transform(
        camera,
        view_transform(
            point3D(8.0, 5.5, -18.0),
            point3D(0.0, 1.3, 0.0),
            vector3D(0.0, 1.0, 0.0),
        ),
    )
    canvas = render_multithread(camera, world)
end

function show_scene()
    canvas = draw_world()
    show_image(canvas)
    save_image(canvas, "renders/teapot_smooth_scene.png")
end
