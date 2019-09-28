module Patterns

export Pattern, stripe_pattern, stripe_at

import Aether.ColorsModule: ColorRGB
import Aether.HomogeneousCoordinates: Vec3D

mutable struct Pattern
    a::ColorRGB
    b::ColorRGB
end

function stripe_pattern(c1::ColorRGB, c2::ColorRGB)
    return Pattern(c1, c2)
end

function stripe_at(pattern::Pattern, point::Vec3D)
    if mod(floor(point.x), 2) == 0
        return pattern.a
    end
    return pattern.b
end

end
