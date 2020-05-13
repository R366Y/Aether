module CanvasModule

using Aether.ColorsModule
using StaticArrays
using Images

export Canvas, write_pixel!, pixel_at, empty_canvas
export show_image_with_default_reader, save_image

"""
    struct Canvas

Canvas is the data structure where the computations of the raytracer is written i.e contains the final image.
Fields `width` and `height` define the width and height of the image.
"""
struct Canvas
    width::Int64
    height::Int64
    __data::Array{ColorRGB,2}

    """
        Canvas(width::Int64, height::Int64)

    Create a canvas filled with black color.
    """
    function Canvas(width::Int64, height::Int64)
        new(width, height, fill(black, (height, width)))
    end

    """
        Canvas(width::Int64, height::Int64, c::ColorRGB)

    Create a canvas filled with color `c`.
    """
    function Canvas(width::Int64, height::Int64, c::ColorRGB)
        new(width, height, fill(c, (height, width)))
    end
end

"""
    empty_canvas(width::Int64, height::Int64)

Create an empty canvas filled with black color. Same as `Canvas(width::Int64, height::Int64)`.
"""
function empty_canvas(width::Int64, height::Int64)
    return Canvas(width, height, black)
end

"""
    write_pixel!(canvas::Canvas, x::Int64, y::Int64, color::ColorRGB)

Write a pixel on a canvas to given coordinates `x` and `y` of color `color`.
"""
function write_pixel!(canvas::Canvas, x::Int64, y::Int64, color::ColorRGB)
    @inbounds canvas.__data[y, x] = color
end

"""
    pixel_at(canvas::Canvas, x::Int64, y::Int64)

Returns the color of a pixel at the given coordinates `x` and `y`.
"""
function pixel_at(canvas::Canvas, x::Int64, y::Int64)
    return canvas.__data[y, x]
end

"""
    show_image_with_default_reader(filename::string)

Show an image with the default image viewer
"""
function show_image_with_default_reader(filename)
    run(`cmd /c mspaint $filename`)
end

"""
    save_image(canvas::Canvas, filename = "renders/render.png")

Saves an image to the hard drive. Optionally file name can be passed to `filename` field.
"""
function save_image(canvas::Canvas, filename = "renders/render.png")
    save(filename, _convertCanvasToRGB(canvas))
    return filename
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
