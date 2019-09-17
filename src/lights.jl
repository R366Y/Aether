module Lights

export PointLight

using Aether.HomogeneousCoordinates
using Aether.ColorsModule

struct PointLight
    position::Vec3D{Float64}
    intensity::ColorRGB
end

end
