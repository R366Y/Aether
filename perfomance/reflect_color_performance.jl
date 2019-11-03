using Aether.ColorsModule
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.BaseGeometricType
using Aether.Lights
using Aether.Patterns
using Aether.Shapes
using Aether.WorldModule
using Aether.Rays
import Aether: ϵ
import Aether.BaseGeometricType: set_transform

using BenchmarkTools

w = default_world()
shape = Plane()
shape.material.reflective = 0.5
set_transform(shape, translation(0., -1., 0.))
add_objects(w, shape)
r = Ray(point3D(0., 0., -3.), vector3D(0., -√2/2, √2/2))
i = Intersection(√2, shape)
comps = prepare_computations(i, r,  Intersection[])
@code_warntype reflected_color(w, comps, 1)
@btime reflected_color(w, comps, 1)
