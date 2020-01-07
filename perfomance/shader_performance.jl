using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.Patterns
using Aether.Shaders
using Aether.Shapes

import Aether: ϵ

using BenchmarkTools

m = default_material()
position = point3D(0., 0., 0.)
eyev = vector3D(0., 0., -1.)
normalv = vector3D(0., 0., -1.)
light = PointLight(point3D(0., 0., -10.), ColorRGB(1., 1., 1.))
@code_warntype lighting(m, default_sphere(), light, position, eyev,
                  normalv, 1.0)

@btime lighting(m, default_sphere(), light, position, eyev,
                  normalv, 1.0)
