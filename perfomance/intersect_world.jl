using Aether.WorldModule
using Aether.Rays
using Aether.HomogeneousCoordinates
using Aether.Shapes
using Aether.BaseGeometricType

using  Profile
using BenchmarkTools

w = default_world()
add_objects(w, Cube())
r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))

@code_warntype intersect_world(w, r)
@benchmark intersect_world(w, r)
