using Aether
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
	obj_file = parse_obj_file("examples/resources/teddy.obj")
	teddy = obj_to_group(obj_file)
    set_transform(teddy,rotation_y(float(π)) * scaling(0.15, 0.15, 0.15))

	world = World()
    add_lights!(world, PointLight(point3D(1.0, 6.9, -4.9), ColorRGB(1.0, 1.0, 1.0)))
    add_objects(world,teddy)

    camera = Camera(400, 200, 0.314)
    camera_set_transform(
        camera,
        view_transform(
            point3D(8.0, 3.5, -40.0),
            point3D(0.0, 0.3, 0.0),
            vector3D(0.0, 1.0, 0.0),
        ),
    )
    canvas = render_multithread(camera, world)
end

function show_scene()
    canvas = draw_world()
    save_image(canvas, "renders/teddy_scene.png")
    show_image_with_default_reader(joinpath("renders", "teddy_scene.png"))
end