module CanvasModule

using Aether.ColorsModule
using StaticArrays
using Images

export Canvas, write_pixel!, pixel_at, show_image, empty_canvas

struct Canvas
    width::Int64
    height::Int64
    __data::Array{Float64,2}

    function Canvas(width::Int64, height::Int64, c::ColorRGB)
        size = width * height
        new(width, height, Array{Float64,2}(repeat([c.r c.g c.b], size)))
    end
end

function empty_canvas(width::Int64, height::Int64)
    return Canvas(width, height, ColorRGB(0., 0., 0.))
end

function write_pixel!(canvas::Canvas, x::Int64, y::Int64, color::ColorRGB)
    canvas.__data[x+(y-1)*canvas.width, :] = [color.r, color.g, color.b]
end

function pixel_at(canvas::Canvas, x::Int64, y::Int64)
    color_array = canvas.__data[x+(y-1)*canvas.width, :]
    return ColorRGB(color_array[1], color_array[2], color_array[3])
end

function show_image(canvas::Canvas)
    display(reshape(
        [RGB(x[1], x[2], x[3]) for x in eachrow(canvas.__data)],
        canvas.width,
        canvas.height
    ) |> transpose);
end

end
