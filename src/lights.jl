module Lights

export LightType, AreaLight, PointLight, default_point_light, point_on_light

import Base: ==
using Aether.HomogeneousCoordinates
using Aether.ColorsModule
using Aether.Utils

abstract type LightType end

struct PointLight <: LightType
    position::Vecf64
    intensity::ColorRGB
end

mutable struct AreaLight <: LightType
    position::Vecf64
    intensity::ColorRGB
    corner::Vecf64
    uvec::Vecf64
    usteps::Int
    vvec::Vecf64
    vsteps::Int
    samples::Int
    jitter_by

    function AreaLight(corner::Vecf64, uvec::Vecf64, usteps::Int, 
                       vvec::Vecf64, vsteps::Int, intensity::ColorRGB)
        uvec = uvec / Float64(usteps)
        vvec = vvec / Float64(vsteps)
        samples = usteps * vsteps
        position = corner + (uvec * (usteps * 0.5)) + (vvec * (vsteps * 0.5))
        new(position, intensity, corner, uvec, usteps,
            vvec, vsteps, samples) 
    end
end

function default_point_light()
    intensity = ColorRGB(1.0, 1.0, 1.0)
    position = point3D(0.0, 0.0, 0.0)
    return PointLight(position, intensity)
end

@inline ==(p1::PointLight, p2::PointLight) =
    p1.position == p2.position && p1.intensity == p2.intensity

"""
    point_on_light(light::AreaLight, u::Int, v::Int)

Returns the point in the middle of the cell at the given coordinates (u,v)
"""
function point_on_light(light::AreaLight, u::Int, v::Int)
    return light.corner + 
           light.uvec * (u + next!(light.jitter_by)) +
           light.vvec * (v + next!(light.jitter_by))
end

end