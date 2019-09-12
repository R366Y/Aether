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
end
