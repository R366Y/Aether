module ColorsModule

import Base: +, -, *, /, ==, isapprox
using StaticArrays

export ColorRGB

struct ColorRGB{T}
    r::T
    g::T
    b::T

    function ColorRGB(r::T=0.0, g::T=0.0, b::T=0.0) where T<:AbstractFloat
        new{T}(r,g,b)
    end
end

#TODO : refactor as Vec3D , implements methods +,*, =
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
        @inline function $(op)(c::ColorRGB, a::T) where T <: AbstractFloat
            return ColorRGB(map(($op), c.r, a),
                            map(($op), c.g, a),
                            map(($op), c.b, a))
        end
    end
end

for op in (:+, :*, :-, :/)
    @eval begin
        @inline function $(op)(a::T, c1::ColorRGB) where T <: AbstractFloat
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
end
