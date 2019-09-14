using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Test

@testset "Lights" begin
    @testset "A point light has position and intensity" begin
        intensity = ColorRGB(1.,1.,1.)
        position = point3D(0.,0.,0.)
        light = PointLight(position, intensity)
        @test light.position == position
        @test light.intensity == intensity
    end
end # begin
