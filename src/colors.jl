module ColorsModule

using StaticArrays
import Base: +, -, *, /, ==, isapprox
import Aether: float_equal

export ColorRGB, black, white

struct ColorRGB
    r::Float64
    g::Float64
    b::Float64

    function ColorRGB(r::Float64=0.0, g::Float64=0.0, b::Float64=0.0)
        new(r,g,b)
    end
end

const black = ColorRGB(0., 0., 0.)
const white = ColorRGB(1., 1., 1.)

for op in (:+, :*, :-)
    @eval begin
        @inline function $(op)(c1::ColorRGB, c2::ColorRGB)
            return ColorRGB(map(($op), c1.r, c2.r),
                            map(($op), c1.g, c2.g),
                            map(($op), c1.b, c2.b))
        end
    end
end

for op in (:+, :*, :-, :/)
    @eval begin
        @inline function $(op)(c::ColorRGB, a::Float64)
            return ColorRGB(map(($op), c.r, a),
                            map(($op), c.g, a),
                            map(($op), c.b, a))
        end
    end
end

for op in (:+, :*, :-, :/)
    @eval begin
        @inline function $(op)(a::Float64, c1::ColorRGB)
            return ColorRGB(map(($op), a, c.r),
                            map(($op), a, c.g),
                            map(($op), a, c.b))
        end
    end
end

@inline ==(c1::ColorRGB, c2::ColorRGB) = c1.r == c2.r &&
                                         c1.g == c2.g &&
                                         c1.b == c2.b

@inline isapprox(c1::ColorRGB, c2::ColorRGB; rtol=√eps()) =
                                    isapprox(c1.r, c2.r, rtol=rtol) &&
                                    isapprox(c1.g, c2.g, rtol=rtol) &&
                                    isapprox(c1.b, c2.b, rtol=rtol)

function float_equal(c1::ColorRGB, c2::ColorRGB)
    return float_equal(c1.r, c2.r) &&
           float_equal(c1.g, c2.g) &&
           float_equal(c1.b, c2.b)
end

end
