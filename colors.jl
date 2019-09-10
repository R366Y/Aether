import Base: +, -, *, /
using StaticArrays

export Color

struct Color{T<:AbstractFloat}
    r::T
    g::T
    b::T
    #__data::SVector{3,T}

    function Color(r::T=0.0, g::T=0.0, b::T=0.0) where T<:AbstractFloat
        new{T}(r,g,b)
    end
end

for op in (:+, :-, :*)
    @eval begin
        function $(op)(c1::Color, c2::Color)
            return Color(
                $(op)(c1.r, c2.r),
                $(op)(c1.g, c2.g),
                $(op)(c1.b, c2.b)
            )
        end
    end
end

for op in (:+, :-, :*, :/)
    @eval begin
        function $(op)(c1::Color, k::T) where T <: AbstractFloat
            return Color($(op)(c1.r, k), $(op)(c1.g, k), $(op)(c1.b, k))
        end
    end

    @eval begin
        function $(op)(k::T, c1::Color) where T <: AbstractFloat
            return Color($(op)(c1.r, k), $(op)(c1.g, k), $(op)(c1.b, k))
        end
    end
end
