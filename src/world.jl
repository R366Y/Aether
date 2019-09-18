module  WorldModule

export World, default_world, add_objects, intersect_world

using Aether
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Lights
using Aether.MatrixTransformations
using Aether.Rays
using Aether.Spheres

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

end  # module WorldModule
