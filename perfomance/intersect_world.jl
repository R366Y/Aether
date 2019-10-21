using Aether.WorldModule
using Aether.Rays
using Aether.HomogeneousCoordinates
using Aether.Shapes
using Aether.Intersections

using  Profile
using BenchmarkTools

w = default_world()
r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
@btime intersect_world(w, r)

function intersect_world_new(world::World, ray::Ray)
    result = Intersection[]
    for obj in world.objects
        xs = r_intersect(obj, ray)
        for i in xs
            splice!(result, searchsorted(result,i, by=x->x.t), [i]); result
        end
    end
    return result
end
# Profile.clear()
# @profile for i = 1:100000; intersect_world(w,r); end
#
# Profile.print(combine=true, format=:flat, sortedby=:filefuncline)
