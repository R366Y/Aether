using StaticArrays
include("colors.jl")

struct Canvas
    width::Int64
    height::Int64
    __data::MMatrix

    function Canvas(width::Int64, height::Int64, c::Color)
        size = width * height
        data = MMatrix{height,width}([c for i = 1:size])
        new(width, height, data)
    end
end

function write_pixel!(canvas::Canvas, x::Int64, y::Int64, color::Color)
    canvas.__data[y, x] = color
end

function pixel_at(canvas::Canvas, x::Int64, y::Int64)
    return canvas.__dat[y, x]
end
