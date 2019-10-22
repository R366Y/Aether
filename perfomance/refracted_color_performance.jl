using Aether.ColorsModule
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Lights
using Aether.Patterns
using Aether.Shapes
using Aether.WorldModule
using Aether.Rays
import Aether: ϵ
import Aether.BaseGeometricType: set_transform

using BenchmarkTools

w = default_world()
a = w.objects[1]
a.material.ambient = 1.
a.material.pattern = TestPattern()
b = w.objects[2]
b.material.transparency = 1.
b.material.refractive_index = 1.5
r = Ray(point3D(0., 0., 0.1), vector3D(0., 1., 0.))
xs = Intersection[Intersection(-0.9899, a), Intersection(-0.4899, b),
                  Intersection(0.4899,b), Intersection(0.9899,a)]
comps = prepare_computations(xs[3], r, xs)
@code_warntype refracted_color(w, comps, 5)
@btime refracted_color(w, comps, 5)
