module ComputationsModule

export Computations, prepare_computations

using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Rays
using Aether.Spheres
using LinearAlgebra
import Aether: GeometricObject

mutable struct Computations{O<:GeometricObject}
    t::Float64
    object::O
    point::Vec3D{Float64}
    eyev::Vec3D{Float64}
    normalv::Vec3D{Float64}
    inside::Bool

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

    # compute if the intersection occurs on the inside
    if dot(comps.normalv, comps.eyev) < 0
        comps.inside = true
        comps.normalv = -comps.normalv
    else
        comps.inside = false
    end
    return comps
end

end  # module ComputationsModule