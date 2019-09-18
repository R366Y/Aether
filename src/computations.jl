module ComputationsModule

export Computations, prepare_computations

using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Rays
using Aether.Spheres
import Aether: GeometricObject

mutable struct Computations{O<:GeometricObject}
    t::Float64
    object::O
    point::Vec3D{Float64}
    eyev::Vec3D{Float64}
    normalv::Vec3D{Float64}

    Computations() = new{GeometricObject}()
end

function prepare_computations(intersection::Intersection, ray::Ray)
    comps = Computations()
    comps.t = intersection.t
    comps.object = intersection.object

    # precompute some useful values
    comps.point = positionr(ray, comps.t)
    comps.eyev = -ray.direction
    comps.normalv = normal_at(comps.object, comps.point)
    return comps
end

end  # module ComputationsModule
