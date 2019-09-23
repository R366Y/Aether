using BenchmarkTools

using Aether.CanvasModule
using Aether.ColorsModule

canvas = empty_canvas(100, 100)

@benchmark write_pixel!(canvas, 20,20, ColorRGB(1., 1., 1.))
println()
@benchmark pixel_at(canvas, 20, 20) 
