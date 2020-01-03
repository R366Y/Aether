using Test
import YAML

const data = YAML.load(open("resources/scene.yml"))

@testset "YAML parser" begin
    @testset "Open a .yml file" begin
        @test !isnothing(data)
    end

    @testset "A scene description has a camera" begin
        camera = data["camera"]
        @test camera["width"] == 100
        @test camera["height"] == 100
        @test camera["field-of-view"] == 0.785
        @test camera["from"] == [ -6, 6, -10 ]
        @test camera["to"] == [ 6, 0, 6 ]
        @test camera["up"] == [ -0.45, 1, 0 ]
    end

    @testset "A scene description has lights" begin
        lights = data["lights"]
        @test length(lights) == 2
        l1 = lights[1]
        l2 = lights[2]
        @test l2["at"] == [ -400, 50, -10 ]
        @test l2["intensity"] == [ 0.2, 0.2, 0.2 ]
    end

    @testset "A scene description can have default materials" begin
        materials = data["materials"]
        m1 = materials[1]
        m2 = materials[2]
        @test m1["color"] == [ 1, 1, 1 ]
        @test m1["diffuse"] == 0.7
        @test m1["ambient"] == 0.1
        @test m1["specular"] == 0.0
        @test m1["reflective"] == 0.1
        @test m2["extend"] == "white-material"
    end

    @testset "A scene description can have default transformations" begin
        transforms = data["transforms"]
        t1 = transforms[1]["value"]
        @test t1[1] == ["translate", 1, 1, 2]
        @test t1[2] == ["scale", 0.5, 0.5, 0.5]
        @test t1[3] == ["rotate-x", 3.14]
        @test t1[4] == ["rotate-y", 1.570796]
        @test t1[5] == ["rotate-z", 0.735]
    end

    @testset "A scene description has objects" begin
        gobjects = data["gobjects"]
        go1 = gobjects[1]
        g02 = gobjects[2]
        m1 = go1["material"]
        t1 = go1["transform"]
        @test m1 == Dict("color"=>[ 1, 1, 1 ], "ambient"=>1, "diffuse"=>0, "specular"=>0)
        @test t1 == [["rotate-x",1.5707963267948966], ["translate",0, 0, 500]]
    end
end