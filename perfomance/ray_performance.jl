using BenchmarkTools

using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
using Aether.Rays

r = Ray(point3D(0., 0., 0.), vector3D(1., 0., 0.))

# @code_warntype positionr(r, 5.)

m = scaling(5., 0., 0.)

@benchmark transform(r, m)
