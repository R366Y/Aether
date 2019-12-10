using Aether.CameraModule
using Aether.CanvasModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Patterns
using Aether.Shapes
using Aether.Renders
using Aether.WorldModule

import Aether.BaseGeometricType: Group, add_child!, set_transform

function draw_world()
	hex = hexagon()

	world = World()
    world.light = PointLight(point3D(1.0, 6.9, -4.9), ColorRGB(1.0, 1.0, 1.0))
    add_objects(world,hex)

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
    save_image(canvas, "renders/hexagon_scene.png")
end

function hexagon_corner()
	corner = default_sphere()
	set_transform(corner, translation(0., 0., -1.) * scaling(0.25, 0.25, 0.25))
	return corner
end

function hexagon_edge()
	edge = Cylinder()
	edge.minimum = 0.
	edge.maximum = 1.
	set_transform(edge, translation(0., 0., -1.) * 
						rotation_y(-π/6) *
						rotation_z(-π/2) *
						scaling(0.25, 1., 0.25))
	return edge
end

function hexagon_side()
	side = Group()
	add_child!(side, hexagon_corner())
	add_child!(side, hexagon_edge())
	return side
end

function hexagon()
	hex = Group()
	for n in 0:5
		side = hexagon_side()
		set_transform(side, rotation_y(n * π/3))
		add_child!(hex, side)
	end
	return hex
end