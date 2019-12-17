using Test
using Aether.CameraModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
using Aether.SceneImporters
using Aether.WorldModule

@testset "Yaml file importer" begin
    @testset "Importer returns an instance of Camera" begin 
        camera, world = import_yaml_scene_file("resources/scene.yml")
        @test camera.hsize == 100
        @test camera.vsize == 100
        @test camera.field_of_view == 0.785
        @test camera.transform == view_transform(point3D(Float64.([ -6, 6, -10 ])),
                                                 point3D(Float64.([ 6, 0, 6 ])),
                                                 vector3D(Float64.([ -0.45, 1, 0 ])))
    end

    @testset "Importer returns an instance of World with lights" begin
        camera, world = import_yaml_scene_file("resources/scene.yml")
        l1 = world.lights[1]
        l2 = world.lights[2]
        @test l1.position == point3D(Float64.([ 50, 100, -50 ]))
        @test l1.intensity == ColorRGB(1., 1., 1.)
        @test l2.position == point3D(Float64.([ -400, 50, -10 ]))
        @test l2.intensity == ColorRGB(0.2, 0.2, 0.2)
    end
end