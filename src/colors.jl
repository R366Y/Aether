module ColorsModule

import Base: +, -, *, /
using StaticArrays

export ColorRGB

struct ColorRGB{T} <: FieldVector{3,T}
    r::T
    g::T
    b::T

    function ColorRGB(r::T=0.0, g::T=0.0, b::T=0.0) where T<:AbstractFloat
        new{T}(r,g,b)
    end
end

end
