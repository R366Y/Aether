module CanvasModule

using Aether.ColorsModule
using StaticArrays
using Images
using ImageView

export Canvas, write_pixel!, pixel_at, show_image, empty_canvas, save_image

struct Canvas
    width::Int64
    height::Int64
    __data::Array{ColorRGB,2}

    function Canvas(width::Int64, height::Int64)
        new(width, height, fill(black, (height, width)))
    end

    function Canvas(width::Int64, height::Int64, c::ColorRGB)
        new(width, height, fill(c, (height, width)))
    end
end

function empty_canvas(width::Int64, height::Int64)
    return Canvas(width, height, black)
end

function write_pixel!(canvas::Canvas, x::Int64, y::Int64, color::ColorRGB)
    @inbounds canvas.__data[y, x] = color
end

function pixel_at(canvas::Canvas, x::Int64, y::Int64)
    return canvas.__data[y, x]
end

function show_image(canvas::Canvas)
    imshow(_convertCanvasToRGB(canvas))
end

function save_image(canvas::Canvas, filename = "renders/render.png")
    save(filename, _convertCanvasToRGB(canvas))
end

function _convertCanvasToRGB(canvas::Canvas)
    result = fill(RGB(0, 0, 0), canvas.height, canvas.width)
    for index in eachindex(canvas.__data)
        result[index] = _colorRGBtoRGB(canvas.__data[index])
    end
    return result
end

function _colorRGBtoRGB(color::ColorRGB)
    r = clamp01(color.r)
    g = clamp01(color.g)
    b = clamp01(color.b)
    return RGB(r, g, b)
end

end
