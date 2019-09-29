using Aether.CameraModule
using Aether.CanvasModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Patterns
using Aether.Planes
using Aether.Spheres
using Aether.WorldModule

import Aether.BaseGeometricType: set_transform

function draw_world()
    the_floor = Plane()
    the_floor.material.pattern = CheckerPattern(white, black)
    wall = Plane()
    wall.material.pattern = RingPattern(white, black)
    set_transform(wall, translation(0., 0., 5.) * rotation_x(π/2))

    middle = default_sphere()
    set_transform(middle, translation(-0.5, 1., 0.5))
    middle.material = default_material()
    middle.material.color = ColorRGB(0.1, 1., 0.5)
    middle.material.diffuse = 0.7
    middle.material.specular = 0.3
    middle.material.pattern = GradientPattern(ColorRGB(1.,0.1,0.2), ColorRGB(0., 0., 1.))
    set_pattern_transform(middle.material.pattern, rotation_z(π/2) * scaling(0.5, 0.5, 0.5))

    right = default_sphere()
    set_transform(right, translation(1.5, 0.5, -0.5) * scaling(0.5, 0.5, 0.5))
    right.material = default_material()
    right.material.color = ColorRGB(0.5, 1., 0.1)
    right.material.diffuse = 0.7
    right.material.specular = 0.3

    left = default_sphere()
    set_transform(left, translation(-1.5, 0.33, -0.75) * scaling(0.33, 0.33, 0.33))
    left.material = default_material()
    left.material.color = ColorRGB(1., 0.8, 0.1)
    left.material.diffuse = 0.7
    left.material.specular = 0.3

    world = World()
    world.light = PointLight(point3D(-10., 10., -10.) , ColorRGB(1., 1., 1.))
    add_objects(world,the_floor,wall, middle, right, left)
    camera = Camera(300, 150, π/3)
    camera.transform = view_transform(point3D(0., 1.5, -5.),
                                      point3D(0., 1., 0.),
                                      vector3D(0., 1., 0.))

    canvas = render(camera, world)
    return canvas
end

function show_scene()
    show_image(draw_world())
end
