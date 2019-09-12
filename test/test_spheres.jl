using Aether.HomogeneousCoordinates
using Aether.Spheres
using Aether.Rays
using Test

@testset "Spheres" begin
    @testset "A ray intersects a sphere in two points" begin
        r = Ray(point3D(0.,0.,-5.), vector3D(0.,0.,1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1] ≈ 4.0
        @test xs[2] ≈ 6.0
    end
    @testset "A ray intersects a sphere at a tangent" begin
        r = Ray(point3D(0.,1.,-5.), vector3D(0.,0.,1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1] ≈ 5.0
        @test xs[2] ≈ 5.0
    end
    @testset "A ray misses a sphere" begin
        r = Ray(point3D(0.,2.,-5.), vector3D(0.,0.,1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 0
    end
    @testset "A ray originates inside a sphere" begin
        r = Ray(point3D(0.,0.,0.), vector3D(0.,0.,1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1] ≈ -1.0
        @test xs[2] ≈ 1.0
    end
    @testset "A sphere is behind the ray" begin
        r = Ray(point3D(0.,0.,5.), vector3D(0.,0.,1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1] ≈ -6.0
        @test xs[2] ≈ -4.0
    end
end
