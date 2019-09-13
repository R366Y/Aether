using Test
using Aether.Rays
using Aether.MatrixTransformations
using Aether.HomogeneousCoordinates

@testset "Rays" begin
    @testset "Creating a ray" begin
        origin = point3D(Float64[1, 2, 3])
        direction = vector3D(Float64[4, 5, 6])
        r = Ray(origin, direction)
        @test r.origin ≈ origin
        @test r.direction ≈ direction
    end

    @testset "Computing a point from a distance" begin
        r = Ray(point3D(Float64[2, 3, 4]), vector3D(Float64[1, 0, 0]))
        @test positionr(r, 0.) ≈ point3D(Float64[2, 3, 4])
        @test positionr(r, 1.) ≈ point3D(Float64[3, 3, 4])
        @test positionr(r, -1.) ≈ point3D(Float64[1, 3, 4])
        @test positionr(r, 2.5) ≈ point3D(Float64[4.5, 3, 4])
    end

    @testset "Translating a ray" begin
        r = Ray(point3D(Float64[1, 2, 3]), vector3D(Float64[0, 1, 0]))
        m = translation(3., 4., 5.)
        r2 = transform(r, m)
        @test r2.origin ≈ point3D(Float64[4, 6, 8])
        @test r2.direction ≈ vector3D(Float64[0, 1, 0])
    end

    @testset "Scaling a ray" begin
        r = Ray(point3D(Float64[1, 2, 3]), vector3D(Float64[0, 1, 0]))
        m = scaling(2., 3., 4.)
        r2 = transform(r, m)
        @test r2.origin ≈ point3D(Float64[2, 6, 12])
        @test r2.direction ≈ vector3D(Float64[0, 3, 0])
    end
end
