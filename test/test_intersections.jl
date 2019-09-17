using Test
using Aether.Spheres
using Aether.Intersections
using Aether.HomogeneousCoordinates
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
