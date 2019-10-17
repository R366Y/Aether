using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
import Aether.Shapes: default_sphere, local_intersect
using Aether.Rays
import Aether.BaseGeometricType: r_intersect

r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
s = default_sphere()
@code_warntype r_intersect(s, r)

local_ray = transform(r, s.inverse)
@code_warntype local_intersect(s, local_ray)
