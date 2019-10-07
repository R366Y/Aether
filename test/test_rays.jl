using Test
using Aether.Rays
using Aether.MatrixTransformations
using Aether.HomogeneousCoordinates

@testset "Rays" begin
    @testset "Creating a ray" begin
        origin = point3D(Float64[1, 2, 3])
        direction = vector3D(Float64[4, 5, 6])
        r = Ray(origin, direction)
        @test float_equal(r.origin, origin)
        @test float_equal(r.direction, direction)
    end

    @testset "Computing a point from a distance" begin
        r = Ray(point3D(Float64[2, 3, 4]), vector3D(Float64[1, 0, 0]))
        @test float_equal(positionr(r, 0.), point3D(Float64[2, 3, 4]))
        @test float_equal(positionr(r, 1.), point3D(Float64[3, 3, 4]))
        @test float_equal(positionr(r, -1.), point3D(Float64[1, 3, 4]))
        @test float_equal(positionr(r, 2.5), point3D(Float64[4.5, 3, 4]))
    end

    @testset "Translating a ray" begin
        r = Ray(point3D(Float64[1, 2, 3]), vector3D(Float64[0, 1, 0]))
        m = translation(3., 4., 5.)
        r2 = transform(r, m)
        @test float_equal(r2.origin, point3D(Float64[4, 6, 8]))
        @test float_equal(r2.direction, vector3D(Float64[0, 1, 0]))
    end

    @testset "Scaling a ray" begin
        r = Ray(point3D(Float64[1, 2, 3]), vector3D(Float64[0, 1, 0]))
        m = scaling(2., 3., 4.)
        r2 = transform(r, m)
        @test float_equal(r2.origin, point3D(Float64[2, 6, 12]))
        @test float_equal(r2.direction, vector3D(Float64[0, 3, 0]))
    end
end
