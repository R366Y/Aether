using Test
using Aether.ColorsModule
using Aether.CanvasModule

@testset "Canvas" begin
    @testset "Creating a canvas" begin
        c = Canvas(10, 20)
        @test c.width == 10
        @test c.height == 20
        @test length(filter(c -> c!= black, c.__data)) == 0
    end

    @testset "Writing pixel to a canvas" begin
        c = Canvas(10, 20)
        red = ColorRGB(1., 0., 0.)
        write_pixel!(c, 2, 3, red)
        @test pixel_at(c, 2, 3) == red
    end
end
