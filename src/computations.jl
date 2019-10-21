module ComputationsModule

export Computations, prepare_computations

import Aether.HomogeneousCoordinates: dot, Vec3D
import Aether.Intersections: Intersection
import Aether.Rays: Ray, positionr, reflect

import Aether: ϵ
import Aether.BaseGeometricType: GeometricObject, normal_at

mutable struct Computations{O<:GeometricObject}
    t::Float64
    object::O
    point::Vec3D{Float64}
    eyev::Vec3D{Float64}
    normalv::Vec3D{Float64}
    inside::Bool
    over_point::Vec3D{Float64}
    under_point::Vec3D{Float64}
    reflectv::Vec3D{Float64}
    n1::Float64
    n2::Float64

    Computations() = new{GeometricObject}()

    function Computations(t::Float64, object::O) where {O<:GeometricObject}
        new{O}(t, object)
    end
end

function prepare_computations(
    intersection::Intersection,
    ray::Ray,
    xs::Array{Intersection},
)
    comps = Computations(intersection.t, intersection.object)

    # precompute some useful values
    comps.point = positionr(ray, comps.t)
    comps.eyev = -ray.direction
    comps.normalv = normal_at(comps.object, comps.point)

    comps.inside = false
    # compute if the intersection occurs on the inside
    if dot(comps.normalv, comps.eyev) < 0.0
        comps.inside = true
        comps.normalv = -comps.normalv
    end
    comps.over_point = comps.point + comps.normalv * ϵ
    comps.under_point = comps.point - comps.normalv * ϵ
    comps.reflectv = reflect(ray.direction, comps.normalv)

    compute_refractive_indices(intersection, xs, comps)
    return comps
end

function compute_refractive_indices(
    intersection::Intersection,
    xs::Array{Intersection},
    comps::Computations
)
    # compute n1 and n2 refractive_index where n1 is material being exited
    # n2 the material being entered
    containers = GeometricObject[]
    for i in xs
        if i == intersection
            if length(containers) == 0
                comps.n1 = 1.0
            else
                comps.n1 = containers[end].material.refractive_index
            end
        end

        if i.object in containers
            filter!(x -> x != i.object, containers)
        else
            push!(containers, i.object)
        end

        if i == intersection
            if length(containers) == 0
                comps.n2 = 1.0
            else
                comps.n2 = containers[end].material.refractive_index
            end
        end
    end
end

end  # module ComputationsModule
