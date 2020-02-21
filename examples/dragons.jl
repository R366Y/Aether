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
    obj_file = parse_obj_file("examples/resources/dragon.obj")
    dragon = obj_to_group(obj_file)
    divide!(dragon, 15)
    set_transform(dragon, scaling(0.268, 0.268, 0.268) * translation(0., 0.1217, 0.) )

    raw_bbox = Cube()
    raw_bbox.shadow = false
    set_transform(raw_bbox,scaling(0.268, 0.268, 0.268) * translation(0., 0.1217, 0.) * translation(-3.9863, -0.1217, -1.1820) * 
                            scaling(3.73335, 2.5845, 1.6283) * translation(1.,1.,1.) )
    raw_bbox.material.ambient = 0.
    raw_bbox.material.diffuse = 0.4
    raw_bbox.material.specular = 0.
    raw_bbox.material.transparency =0.6
    raw_bbox.material.refractive_index = 1.

    pedestal = Cylinder()
    pedestal.minimum = -0.15
    pedestal.maximum = 0.
    pedestal.closed = true
    pedestal.material.color = ColorRGB(0.2, 0.2, 0.2)
    pedestal.material.ambient = 0.
    pedestal.material.diffuse = 0.8
    pedestal.material.specular = 0.
    pedestal.material.reflective = 0.2

    group = Group()
    add_child!(group, pedestal)
    add_child!(group, dragon)
    add_child!(group, raw_bbox)
    set_transform(group, translation(0., 2., 0.))

    group2 = Group()
    add_child!(group2, pedestal)
    add_child!(group2, dragon)
    set_transform(group2, translation(0., 0.5, -4.))

    world = World()

    l1 = PointLight(point3D(-10.0, 100., -100.), ColorRGB(1., 1., 1.))
    l2 = PointLight(point3D(0., 100., 0.), ColorRGB(0.1, 0.1, 0.1))
    l3 = PointLight(point3D(100., 10., -25.), ColorRGB(0.2, 0.2, 0.2))
    l4 = PointLight(point3D(-100., 10., -25.), ColorRGB(0.2, 0.2, 0.2))

    add_lights!(world, l1, l2, l3, l4)
    add_objects(world, group, group2)

    camera = Camera(500, 200, 1.2)
    camera_set_transform(
        camera,
        view_transform(
            point3D(0.0, 2.5, -10.0),
            point3D(0.0, 1.0, 0.0),
            vector3D(0.0, 1.0, 0.0),
        ),
    )
    canvas = render_multithread(camera, world)
end

function show_scene()
canvas = draw_world()
show_image(canvas)
end
