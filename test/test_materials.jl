using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Materials
using Aether.Spheres


using Test

@testset "Materials" begin
    @testset "The default material" begin
        m = default_material()
        @test m.color == ColorRGB(1., 1., 1.)
        @test m.ambient == 0.1
        @test m.diffuse == 0.9
        @test m.specular == 0.9
        @test m.shininess == 200.0
    end
end
