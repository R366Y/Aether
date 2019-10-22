using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations

using BenchmarkTools

from = point3D(1., 3., 2.)
to = point3D(4., -2., 8.)
up = vector3D(1., 1., 0.)
@code_warntype view_transform(from, to, up)
@btime view_transform(from, to, up)
