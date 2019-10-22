using Aether.BaseGeometricType
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.WorldModule
using Aether.Rays
using Aether.MatrixTransformations
using Aether.Shapes

import Aether.ComputationsModule: compute_refractive_indices!

using BenchmarkTools

a = glass_sphere()
set_transform(a, scaling(2., 2., 2.))
a.material.refractive_index = 1.5
b = glass_sphere()
set_transform(b, translation(0., 0., -0.25))
b.material.refractive_index = 2.0
c = glass_sphere()
set_transform(c, translation(0., 0., 0.25))
c.material.refractive_index = 2.5
r = Ray(point3D(0., 0., -4.), vector3D(0., 0., 1.))
xs = Intersection[Intersection(2., a), Intersection(2.75, b),
                 Intersection(3.25, c), Intersection(4.75, b),
                 Intersection(5.25, c), Intersection(6., a)]

comps = prepare_computations(xs[2], r, xs)
@code_warntype compute_refractive_indices!(xs[2], xs, comps)
