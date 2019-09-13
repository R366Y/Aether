using Test
using Aether.Spheres
using Aether.Intersections

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
