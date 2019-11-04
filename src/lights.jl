module Lights

export PointLight, default_point_light

import Base: ==
using Aether.HomogeneousCoordinates
using Aether.ColorsModule

struct PointLight
    position::Vec3D{Float64}
    intensity::ColorRGB
end

function default_point_light()
    intensity = ColorRGB(1.0, 1.0, 1.0)
    position = point3D(0.0, 0.0, 0.0)
    return PointLight(position, intensity)
end

@inline ==(p1::PointLight, p2::PointLight) =
    p1.position == p2.position && p1.intensity == p2.intensity

end
