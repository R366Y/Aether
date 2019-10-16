using Test

using Aether.CameraModule
using Aether.CanvasModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
using Aether.WorldModule
import Aether: float_equal

@testset "Camera" begin
    @testset "The pixel size for a horizontal canvas" begin
        c = Camera(200, 125, π/2)
        @test float_equal(c.pixel_size, 0.01)
    end

    @testset "The pixel for a vertical canvas" begin
        c = Camera(125, 200, π/2)
        @test float_equal(c.pixel_size, 0.01)
    end

    @testset "Constructing a ray through the center of the canvas" begin
        c = Camera(201, 101, π/2)
        r = ray_for_pixel(c, 100, 50)
        @test float_equal(r.origin, point3D(0., 0., 0.))
        @test float_equal(r.direction, vector3D(0., 0., -1.))
    end

    @testset "Constructing a ray through a corner of the canvas" begin
        c = Camera(201, 101, π/2)
        r = ray_for_pixel(c, 0, 0)
        @test float_equal(r.origin, point3D(0., 0., 0.))
        @test float_equal(r.direction, vector3D(0.66519, 0.33259, -0.66851))
    end

    @testset "Constructing a ray when the camera is transformed" begin
        c = Camera(201, 101, π/2)
        camera_set_transform(c, rotation_y(π/4) * translation(0., -2., 5.))
        r = ray_for_pixel(c, 100, 50)
        @test float_equal(r.origin, point3D(0., 2., -5.))
        @test float_equal(r.direction, vector3D(√2/2, 0., -√2/2))
    end

    @testset "Rendering a world with a camera" begin
        w = default_world()
        c = Camera(11, 11, π/2)
        from = point3D(0., 0., -5.)
        to = point3D(0., 0., 0.)
        up = vector3D(0., 1., 0.)
        camera_set_transform(c, view_transform(from, to, up))
        image = render(c, w)
        @test float_equal(pixel_at(image, 5, 5), ColorRGB(0.38066, 0.47583, 0.2855))
    end
end
