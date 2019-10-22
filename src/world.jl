module WorldModule

export World,
       default_world,
       add_objects,
       intersect_world,
       color_at,
       shade_hit,
       render,
       is_shadowed,
       reflected_color,
       refracted_color,
       schlick,
       render_multithread

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
using Aether.Shapes

using Base.Threads
using LinearAlgebra
using ProgressMeter

import Aether.BaseGeometricType: GeometricObject, r_intersect, set_transform

mutable struct World{T<:GeometricObject}
    objects::Array{T,1}
    light::PointLight

    function World()
        new{GeometricObject}(GeometricObject[], default_point_light())
    end
end

function default_world()
    light = PointLight(point3D(-10.0, 10.0, -10.0), ColorRGB(1.0, 1.0, 1.0))
    s1 = default_sphere()
    s1.material.color = ColorRGB(0.8, 1.0, 0.6)
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

function render(camera::Camera, world::World, progress_meter = true)
    image = empty_canvas(camera.hsize, camera.vsize)
    p = Progress(camera.hsize * camera.vsize)
    for x = 1:camera.hsize
        for y = 1:camera.vsize
            ray = ray_for_pixel(camera, x, y)
            color = color_at(world, ray, 5)
            write_pixel!(image, x, y, color)
            if progress_meter
                ProgressMeter.next!(p)
            end
        end
    end
    return image
end

function render_multithread(camera::Camera, world::World)
    # Initialize the progress bar
    p = Progress(camera.hsize * camera.vsize)
    update!(p, 0)
    jj = Threads.Atomic{Int}(0)
    # Setting the number of BLAS threads to 1 so they do not interfere
    # with our threads
    BLAS.set_num_threads(1)

    # divide the horizontal size of our image by the number of threads
    # and save also the reminder
    len, rem = divrem(camera.hsize, nthreads())
    image = empty_canvas(camera.hsize, camera.vsize)

    #Split the image equally among the threads
    num_threads = nthreads()
    sub_images = []
    for t = 1:num_threads
        push!(sub_images, empty_canvas(len, camera.vsize))
    end

    # map every subimage to a given thread
    @threads for t = 1:num_threads
        sub_image = sub_images[t]
        for x in (1:len) .+ (t - 1) * len
            for y = 1:camera.vsize
                ray = ray_for_pixel(camera, x, y)
                color = color_at(world, ray, 5)
                write_pixel!(sub_image, (x - (t - 1) * len), y, color)

                Threads.atomic_add!(jj, 1)
                Threads.threadid() == 1 && update!(p, jj[])
            end
        end
    end

    # process the remaining data in case the image width is not an
    # even number
    remaining = camera.hsize - rem
    remaining_subimage = empty_canvas(rem, camera.vsize)
    for x = remaining+1:camera.hsize
        for y = 1:camera.vsize
            ray = ray_for_pixel(camera, x, y)
            color = color_at(world, ray, 5)
            write_pixel!(image, x - remaining, y, color)

            Threads.atomic_add!(jj, 1)
            update!(p, jj[])
        end
    end

    ProgressMeter.finish!(p)
    BLAS.set_num_threads(num_threads)

    # recombine the subimages into a single image
    for t = 1:num_threads
        image.__data[:, (1:len).+(t-1)*len] .= sub_images[t].__data
    end
    image.__data[:, remaining+1:camera.hsize] .= remaining_subimage.__data

    return image
end

function color_at(world::World, ray::Ray, remaining::Int64)
    intersections = intersect_world(world, ray)
    i = hit(intersections)
    color = black
    if i != nothing
        comps = prepare_computations(i, ray, intersections)
        color = shade_hit(world, comps, remaining)
    end
    return color
end

function shade_hit(world::World, comps::Computations, remaining::Int64)
    shadowed = is_shadowed(world, comps.over_point)
    surface = lighting(
        comps.gobject.material,
        comps.gobject,
        world.light,
        comps.over_point,
        comps.eyev,
        comps.normalv,
        shadowed,
    )
    reflected = reflected_color(world, comps, remaining)
    refracted = refracted_color(world, comps, remaining)

    material = comps.gobject.material
    if material.reflective > 0.0 && material.transparency > 0.0
        reflectance = schlick(comps)
        return surface + reflected * reflectance + refracted * (1 - reflectance)
    else
        return surface + reflected + refracted
    end
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
        sort!(result, by = i -> i.t)
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
    if comps.gobject.material.reflective == 0.0 || remaining <= 0
        return black
    end

    reflect_ray = Ray(comps.over_point, comps.reflectv)
    color = color_at(world, reflect_ray, remaining - 1)
    return color * comps.gobject.material.reflective
end

function refracted_color(world::World, comps::Computations, remaining::Int64)
    if comps.gobject.material.transparency == 0.0 || remaining == 0
        return black
    end
    # Find the ratio of the first index of the refraction to the second
    # Inverted definition of the Snell's Law
    n_ratio = comps.n1 / comps.n2
    cos_i = dot(comps.eyev, comps.normalv)
    # Find sin(θ)^2 via trigonometri identity
    sin2_t = n_ratio^2 * (1 - cos_i^2)
    if sin2_t > 1.0
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
            comps.gobject.material.transparency
    return color
end

function schlick(comps::Computations)
    # Approximation of Fresnel Effect

    cosv = dot(comps.eyev, comps.normalv)
    # total internal reflection can only occur if n1 > n2
    if comps.n1 > comps.n2
        n = comps.n1 / comps.n2
        sin2_t = n^2 * (1.0 - cosv^2)
        if sin2_t > 1.0
            return 1.0
        end
        # compute cosine of theta_t using trigonometric identity
        cos_t = √(1.0 - sin2_t)
        # when n1 > n2, use cos(theta_t) instead
        cosv = cos_t
    end
    r0 = ((comps.n1 - comps.n2) / (comps.n1 + comps.n2))^2
    return r0 + (1.0 - r0) * (1 - cosv)^5
end

end  # module WorldModule
