module  WorldModule

export World, default_world, add_objects, intersect_world,
       color_at, shade_hit, render, is_shadowed

using Aether.CameraModule
using Aether.CanvasModule
using Aether.ColorsModule
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Lights
using Aether.MatrixTransformations
using Aether.Rays
using Aether.Shaders
using Aether.Spheres

using LinearAlgebra

import Aether.BaseGeometricType: GeometricObject, r_intersect, set_transform

mutable struct World{T<:GeometricObject}
    objects::Array{T}
    light::PointLight

    function World()
        new{GeometricObject}(GeometricObject[], default_point_light())
    end
end

function default_world()
    light = PointLight(point3D(-10., 10., -10.), ColorRGB(1., 1., 1.))
    s1 = default_sphere()
    s1.material.color = ColorRGB(0.8, 1., 0.6)
    s1.material.diffuse = 0.7
    s1.material.specular = 0.2

    s2 = default_sphere()
    set_transform(s2, scaling(0.5, 0.5, 0.5))
    w = World()
    w.light = light
    push!(w.objects, s1, s2)
    return w
end

function add_objects(world::World, objs...)
    push!(world.objects, objs...)
end

function intersect_world(world::World, ray::Ray)
    result = Intersection[]
    for obj in world.objects
        xs = r_intersect(obj, ray)
        if length(xs) != 0
            push!(result, xs...)
        end
    end
    if length(result) != 0
        sort!(result, by = i->i.t)
    end
    return result
end

function is_shadowed(world::World, point::Vec3D)
    v = world.light.position - point
    distance = norm(v)
    direction = normalize(v)

    r = Ray(point, direction)
    intersections = intersect_world(world, r)

    h = hit(intersections)
    if h != nothing && h.t < distance
        return true
    end
    return false
end

function shade_hit(world::World, comps::Computations)
    return lighting(comps.object.material, world.light,
                    comps.over_point, comps.eyev, comps.normalv,
                    is_shadowed(world, comps.over_point))
end

function color_at(world::World, ray::Ray)
    intersections = intersect_world(world, ray)
    i = hit(intersections)
    color = ColorRGB(0., 0., 0.)
    if i != nothing
        comps = prepare_computations(i, ray)
        color = shade_hit(world, comps)
    end
    return color
end

function render(camera::Camera, world::World)
    image = empty_canvas(camera.hsize, camera.vsize)

    for y in 1:camera.vsize
        for x in 1:camera.hsize
            ray = ray_for_pixel(camera, x, y)
            color = color_at(world, ray)
            write_pixel!(image, x, y, color)
        end
    end
    return image
end
end  # module WorldModule
