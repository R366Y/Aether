__precompile__(true)

module RayTracer
    include("homogeneous_coordinates.jl")
    include("colors.jl")
    include("canvas.jl")
    include("matrix_transformations.jl")

    export
        point3D, vector3D, cross_product,
        Color,
        Canvas, write_pixel!, pixel_at,
        translation, scaling, rotation_x
end
