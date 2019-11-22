module ColorsModule

using StaticArrays
import Base: +, -, *, /, ==
import Aether: float_equal

export ColorRGB, black, white

"""
    struct ColorRGB

Struct defining colors used by the raytracer. 
'r','g','b' components are floats with range from 0.0 to 1.0.
Allowed operations among colors are '+','-','*'.
Allowed operations bewteen colors and floats are '+','-','*','/'.
"""
struct ColorRGB
    r::Float64
    g::Float64
    b::Float64

    function ColorRGB(r::Float64 = 0.0, g::Float64 = 0.0, b::Float64 = 0.0)
        new(r, g, b)
    end
end

const black = ColorRGB(0.0, 0.0, 0.0)
const white = ColorRGB(1.0, 1.0, 1.0)

for op in (:+, :*, :-)
    @eval begin
        @inline function $(op)(c1::ColorRGB, c2::ColorRGB)
            return ColorRGB(
                map(($op), c1.r, c2.r),
                map(($op), c1.g, c2.g),
                map(($op), c1.b, c2.b),
            )
        end
    end
end

for op in (:+, :*, :-, :/)
    @eval begin
        @inline function $(op)(c::ColorRGB, a::Float64)
            return ColorRGB(
                map(($op), c.r, a),
                map(($op), c.g, a),
                map(($op), c.b, a),
            )
        end
    end
end

for op in (:+, :*, :-, :/)
    @eval begin
        @inline function $(op)(a::Float64, c1::ColorRGB)
            return ColorRGB(
                map(($op), a, c.r),
                map(($op), a, c.g),
                map(($op), a, c.b),
            )
        end
    end
end

@inline ==(c1::ColorRGB, c2::ColorRGB) =
    c1.r == c2.r && c1.g == c2.g && c1.b == c2.b

function float_equal(c1::ColorRGB, c2::ColorRGB)
    return float_equal(c1.r, c2.r) &&
           float_equal(c1.g, c2.g) && float_equal(c1.b, c2.b)
end

end
