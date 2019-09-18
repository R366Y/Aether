using Test
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Spheres
using Aether.Rays

@testset "Intersections" begin
    @testset "Intersection encapsulates t and object" begin
        s = default_sphere()
        i = Intersection(3.5, s)
        @test i.t == 3.5
        @test i.object == s
    end

    @testset "Hit when all intersections have positive t" begin
        s = default_sphere()
        i1 = Intersection(1., s)
        i2 = Intersection(2., s)
        i = hit((i2,i1))
        @test i === i1
    end

    @testset "Hit when all intersections have negative t" begin
        s = default_sphere()
        i1 = Intersection(-1., s)
        i2 = Intersection(-2., s)
        i = hit((i2,i1))
        @test i === nothing
    end

    @testset "Hit one intersection have negative t" begin
        s = default_sphere()
        i1 = Intersection(-1., s)
        i = hit((i1,))
        @test i === nothing
    end

    @testset "Hit is always the lowest nonnegative intersection" begin
        s = default_sphere()
        i1 = Intersection(5., s)
        i2 = Intersection(7., s)
        i3 = Intersection(-3., s)
        i4 = Intersection(2., s)
        i = hit((i2,i1,i4,i3))
        @test i === i4
    end
end

@testset "Reflecting vectors" begin
    @testset "Reflecting a vector approaching at 45°" begin
        v = vector3D(1., -1., 0.)
        n = vector3D(0., 1., 0.)
        r = reflect(v, n)
        @test r == vector3D(1., 1., 0.)
    end
    @testset "Reflecting a vector off a slanted surface" begin
        v = vector3D(0., -1., 0.)
        n = vector3D(√2/2, √2/2, 0.)
        r = reflect(v, n)
        @test r ≈ vector3D(1., 0., 0.)
    end
end

@testset "Computations" begin
    @testset "Precomputing the test of an intersection" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        shape = default_sphere()
        i = Intersection(4., shape)
        comps = prepare_computations(i, r)
        @test comps.t == i.t
        @test comps.object == shape
        @test comps.point == point3D(0., 0., -1.)
        @test comps.eyev == vector3D(0., 0., -1.)
        @test comps.normalv == vector3D(0., 0., -1.)
    end
end
