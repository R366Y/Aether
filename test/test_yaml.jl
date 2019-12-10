using Test
import YAML

@testset "YAML parser" begin
    @testset "Open a .yml file" begin
        data = YAML.load(open("resources/scene.yml"))
        println(data)
    end
end