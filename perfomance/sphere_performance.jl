using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
using Aether.Spheres
using Aether.Rays

using BenchmarkTools

r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
s = default_sphere()
@code_warntype r_intersect(s, r)
