using Test
using StaticArrays
using LinearAlgebra

using Aether.HomogeneousCoordinates
@testset "Homogeneous Coordinates" begin
    @testset "coordinates" begin
        @test point3D(4.0, -4.0, 3.0) == Vec3D(4.0, -4.0, 3.0, 1.0)
        @test vector3D(4.0, -4.0, 3.0) == Vec3D(4.0, -4.0, 3.0, 0.0)
    end

    @testset "operations" begin
        a1 = point3D(3.0, -2.0, 5.0)
        a2 = vector3D(-2.0, 3.0, 1.0)
        @test a1 + a2 == point3D(1.0, 1.0, 6.0)

        v1 = vector3D(Float64[3, 2, 1])
        v2 = vector3D(Float64[5, 6, 7])
        @test v1 - v2 == vector3D(-2.0, -4.0, -6.0)
    end

    @testset "magnitude" begin
        v = vector3D(Float64[1, 0, 0])
        @test norm(v) == 1

        v = vector3D(Float64[1, 2, 3])
        @test norm(v) ≈ √(14)
    end

    @testset "normalization" begin
        v = vector3D(Float64[1, 2, 3])
        @test normalize(v) ≈ vector3D(1 / √14, 2 / √14, 3 / √14)

        v = vector3D(Float64[1, 2, 3])
        normalized = normalize(v)
        @test norm(normalized) == 1
    end

    @testset "dotproduct" begin
        a = vector3D(Float64[1, 2, 3])
        b = vector3D(Float64[2, 3, 4])
        @test dot(a, b) == 20
    end

    @testset "cross product" begin
        a = vector3D(Float64[1, 2, 3])
        b = vector3D(Float64[2, 3, 4])
        @test cross_product(a, b) == vector3D(Float64[-1, 2, -1])
    end
end
