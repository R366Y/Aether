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
    set_transform(dragon, scaling(0.268, 0.268, 0.268) * translation(0., 0.1217, 0.) )

    raw_bbox = Cube()
    raw_bbox.shadow = false
    set_transform(raw_bbox,scaling(0.268, 0.268, 0.268) * translation(0., 0.1217, 0.) * translation(-3.9863, -0.1217, -1.1820) * 
                            scaling(3.73335, 2.5845, 1.6283) * translation(1.,1.,1.) )
    ambient!(raw_bbox.material, 0.)
    diffuse!(raw_bbox.material, 0.4)
    specular!(raw_bbox.material, 0.)
    transparency!(raw_bbox.material, 0.6)
    refractive_index!(raw_bbox.material, 1.)

    pedestal = Cylinder()
    pedestal.minimum = -0.15
    pedestal.maximum = 0.
    pedestal.closed = true
    color!(pedestal.material, ColorRGB(0.2, 0.2, 0.2))
    ambient!(pedestal.material, 0.)
    diffuse!(pedestal.material, 0.8)
    specular!(pedestal.material, 0.)
    reflective!(pedestal.material, 0.2)

    group = Group()
    dm1 = default_material()
    color!(dm1, ColorRGB(1., 0., 0.1))
    ambient!(dm1, 0.1)
    diffuse!(dm1, 0.6)
    specular!(dm1, 0.3)
    shininess!(dm1, 15.)
    
    d1 = deepcopy(dragon)
    apply_material(d1, dm1)

    add_child!(group, deepcopy(pedestal))
    add_child!(group, d1)
    add_child!(group, deepcopy(raw_bbox))
    set_transform(group, translation(0., 2., 0.))

    group2 = Group()
    add_child!(group2, deepcopy(pedestal))
    add_child!(group2, deepcopy(dragon))
    set_transform(group2, translation(0., 0.5, -4.))

    group3 = Group()
    set_transform(group3, translation(2., 1., -1.))
    add_child!(group3, deepcopy(pedestal))
    group3_1 = Group()
    set_transform(group3_1, scaling(0.75, 0.75, 0.75) * rotation_y(4.))
    add_child!(group3_1, deepcopy(dragon))
    add_child!(group3_1, deepcopy(raw_bbox))
    add_child!(group3, group3_1)

    group4 = Group()
    set_transform(group4, translation(-2., 0.75, -1.))
    add_child!(group4, deepcopy(pedestal))
    group4_1 = Group()
    set_transform(group4_1, scaling(0.75, 0.75, 0.75) * rotation_y(-0.4))
    add_child!(group4_1, deepcopy(dragon))
    add_child!(group4_1, deepcopy(raw_bbox))
    add_child!(group4, group4_1)

    scene = Group()
    add_child!(scene, group)
    add_child!(scene, group2)
    add_child!(scene, group3)
    add_child!(scene, group4)
    divide!(scene, 5)

    world = World()

    l1 = PointLight(point3D(-10.0, 100., -100.), ColorRGB(1., 1., 1.))
    l2 = PointLight(point3D(0., 100., 0.), ColorRGB(0.1, 0.1, 0.1))
    l3 = PointLight(point3D(100., 10., -25.), ColorRGB(0.2, 0.2, 0.2))
    l4 = PointLight(point3D(-100., 10., -25.), ColorRGB(0.2, 0.2, 0.2))

    add_lights!(world, l1, l2, l3, l4)
    add_objects(world, scene)

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
