module  WorldModule

export World, default_world, add_objects, intersect_world,
       color_at, shade_hit, render, is_shadowed, reflected_color,
       refracted_color

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

function reflected_color(world::World, comps::Computations, remaining::Int64)
    if comps.object.material.reflective == 0. || remaining <= 0
        return black
    end

    reflect_ray = Ray(comps.over_point, comps.reflectv)
    color = color_at(world, reflect_ray, remaining - 1)
    return color * comps.object.material.reflective
end

function refracted_color(world::World, comps::Computations, remaining::Int64)
    if comps.object.material.transparency == 0. || remaining == 0
        return black
    end
    # Find the ratio of the first index of the refraction to the second
    # Inverted definition of the Snell's Law
    n_ratio = comps.n1 / comps.n2
    cos_i = dot(comps.eyev, comps.normalv)
    # Find sin(θ)^2 via trigonometri identity
    sin2_t = n_ratio^2 * (1- cos_i^2)
    if sin2_t > 1.
        return black
    end

    # Find cos(θt) via trigonometric identity
    cos_t = √(1 - sin2_t)
    # Compute the direction of the refracted ray
    direction = comps.normalv * (n_ratio * cos_i - cos_t) - comps.eyev * n_ratio
    # Create the refracted ray
    refracted_ray = Ray(comps.under_point, direction)

    # Find the color of the refracted ray, making sure to multiply
    # by the transparency value to account for any opacity
    color = color_at(world, refracted_ray, remaining - 1) *
            comps.object.material.transparency
    return color
end

function shade_hit(world::World, comps::Computations, remaining::Int64)
    shadowed = is_shadowed(world, comps.over_point)
    surface = lighting(comps.object.material,comps.object, world.light,
                    comps.over_point, comps.eyev, comps.normalv,
                    shadowed)
    reflected = reflected_color(world, comps, remaining)
    refracted = refracted_color(world, comps, remaining)
    return surface + reflected + refracted
end

function color_at(world::World, ray::Ray, remaining::Int64)
    intersections = intersect_world(world, ray)
    i = hit(intersections)
    color = ColorRGB(0., 0., 0.)
    if i != nothing
        comps = prepare_computations(i, ray, intersections)
        color = shade_hit(world, comps, remaining)
    end
    return color
end

function render(camera::Camera, world::World)
    image = empty_canvas(camera.hsize, camera.vsize)

    for y in 1:camera.vsize
        for x in 1:camera.hsize
            ray = ray_for_pixel(camera, x, y)
            color = color_at(world, ray, 5)
            write_pixel!(image, x, y, color)
        end
    end
    return image
end
end  # module WorldModule
