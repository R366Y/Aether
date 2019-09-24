using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.WorldModule
using Aether.Rays

using BenchmarkTools

w = default_world()
r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
shape = w.objects[1]
i = Intersection(4., shape)

t = @benchmark prepare_computations(i, r)

println(minimum(t))
println(median(t))
