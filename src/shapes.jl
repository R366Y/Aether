module Shapes

export Cone, Cube, Cylinder, Plane, Sphere, TestShape,
       default_sphere, glass_sphere, add_child

include("cones.jl")
include("cubes.jl")
include("cylinder.jl")
include("planes.jl")
include("spheres.jl")
include("test_shape.jl")

end  # module
