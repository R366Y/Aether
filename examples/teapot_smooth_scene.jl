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
	obj_file = parse_obj_file("examples/resources/teapot_smooth.obj")
	teapot = obj_to_group(obj_file)
	divide!(teapot, 15)
    set_transform(teapot, scaling(0.15, 0.15, 0.15) * rotation_x(-π/2))

	world = World()
    world.light = PointLight(point3D(1.0, 6.9, -4.9), ColorRGB(1.0, 1.0, 1.0))
    add_objects(world,teapot)

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
