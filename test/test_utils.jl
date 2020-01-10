using Test
using Aether.Utils

@testset "A number generator returns a cyclic sequence of numbers" begin
    g = Generator(0.1, 0.5, 1.0)
    @test next!(g) == 0.1
    @test next!(g) == 0.5
    @test next!(g) == 1.0
    @test next!(g) == 0.1
end