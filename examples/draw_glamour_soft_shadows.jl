using Aether.BaseGeometricType
using Aether.CameraModule
using Aether.CanvasModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Shapes
using Aether.Renders
using Aether.Utils
using Aether.WorldModule

function draw_world()
    world = World()
    area_light = AreaLight(point3D(-1.0, 2.0, 4.0), vector3D(2., 0., 0.), 8, vector3D(0., 2., 0.), 8, ColorRGB(1.5, 1.5, 1.5))
    area_light.jitter_by = RandomGenerator(13)
    point_light = PointLight(point3D(-1.0, 2.0, 4.0), white)
    add_lights!(world, area_light)

    # Put the light in the middle of a "shining" cube so that it can show
    # up in reflections as a physical thing. Naturally, the cube must
    # opt out of shadow tests...
    c = Cube()
    c.material.color = ColorRGB(1.5, 1.5, 1.5)
    c.material.ambient = 1.0
    c.material.diffuse = 0.0
    c.material.specular = 0.0
    set_transform(c, translation(0., 3., 4.) * scaling(1., 1., 0.01))
    c.shadow = false

    s1 = default_sphere()
    set_transform(s1,translation(0.5, 0.5, 0.) * scaling(0.5, 0.5, 0.5))
    s1.material.color = ColorRGB(1., 0., 0.)
    s1.material.ambient = 0.1
    s1.material.specular = 0.
    s1.material.diffuse = 0.6
    s1.material.reflective = 0.3

    s2 = default_sphere()
    set_transform(s2, translation(-0.25, 0.33, 0.) * scaling(0.33, 0.33, 0.3))
    s2.material.color = ColorRGB(0.5, 0.5, 1.)
    s2.material.ambient = 0.1
    s2.material.specular = 0.
    s2.material.diffuse = 0.6
    s2.material.reflective = 0.3

    the_floor = Plane()
    the_floor.material.color = white
    the_floor.material.ambient = 0.025
    the_floor.material.diffuse = 0.67
    the_floor.material.specular = 0

    spheres = group_of(GeometricObject[s1,s2])

    add_objects(world,the_floor, spheres, c)
    camera = Camera(800, 320, π/3)
    camera_set_transform(camera, view_transform(
                                      point3D(-3., 1., 2.5),
                                      point3D(0., 0.5, 0.),
                                      vector3D(0., 1., 0.)))
    canvas = render_multithread(camera, world)
    return canvas
end

function show_scene()
    canvas = draw_world()
    save_image(canvas, "renders/glamour_soft_shadows.png")
    show_image_with_default_reader(joinpath("renders", "glamour_soft_shadows.png"))
end