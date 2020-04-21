using Test
using Aether.CameraModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Materials
using Aether.MatrixTransformations
using Aether.SceneImporters
using Aether.Shapes
using Aether.WorldModule

import YAML
import Aether.SceneImporters: parse_materials_data, parse_transforms_data

@testset "Yaml file importer" begin
    @testset "Importer returns an instance of Camera" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene.yml")
        @test camera.hsize == 100
        @test camera.vsize == 100
        @test camera.field_of_view == 0.785
        @test camera.transform == view_transform(point3D(Float64.([ -6, 6, -10 ])),
                                                 point3D(Float64.([ 6, 0, 6 ])),
                                                 vector3D(Float64.([ -0.45, 1, 0 ])))
    end

    @testset "Importer returns an instance of World with lights" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene.yml")
        l1 = lights[1]
        l2 = lights[2]
        @test l1.position == point3D(Float64.([ 50, 100, -50 ]))
        @test l1.intensity == ColorRGB(1., 1., 1.)
        @test l2.position == point3D(Float64.([ -400, 50, -10 ]))
        @test l2.intensity == ColorRGB(0.2, 0.2, 0.2)
    end

    @testset "Test parsing predefined materials if present" begin
        data = YAML.load(open("resources/scene.yml"))
        materials = parse_materials_data(data)
        white_mat = materials["white-material"]
        blue_mat = materials["blue-material"]
        @test white_mat.color == ColorRGB(1., 1., 1.)
        @test white_mat.diffuse == 0.7
        @test white_mat.ambient == 0.1
        @test white_mat.specular == 0.0
        @test white_mat.reflective == 0.1
        @test blue_mat.color == ColorRGB(0.537, 0.831, 0.914)
    end

    @testset "Test parsing predefined transformations if present" begin
        data = YAML.load(open("resources/scene.yml"))
        transformations = parse_transforms_data(data)
        standard_t = transformations["standard-transform"]
        large_obj_t = transformations["large-object"]
        @test standard_t[1][2] == rotation_z(0.735)
        @test standard_t[2][2] == rotation_y(1.570796)
        @test standard_t[3][2] == rotation_x(3.14)
        @test standard_t[4][2] == scaling(0.5, 0.5, 0.5)
        @test standard_t[5][2] == translation(1., 1., 2.)
        @test large_obj_t[1][2] == rotation_z(0.8)
    end

    @testset "Importer returns an instance of World with objects" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene.yml")
        plane = gobjects[1]
        material = default_material()
        material.color = ColorRGB(1., 1., 1.)
        material.ambient = 1.
        material.diffuse = 0.
        material.specular = 0.
        @test typeof(plane) == Plane
        @test plane.material == material
        @test plane.transform == translation(0., 0., 500.) * rotation_x(1.5707963267948966)
    end

    @testset "World objects' materials can extend a predefined material" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene.yml")
        sphere = gobjects[2]
        white_mat = sphere.material
        @test white_mat.color == ColorRGB(1., 1., 1.)
        @test white_mat.diffuse == 0.7
        @test white_mat.ambient == 0.1
        @test white_mat.specular == 0.0
        @test white_mat.reflective == 0.1
    end

    @testset "World objects' materials can extend a predefined transformation" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene.yml")
        sphere = gobjects[2]
        @test sphere.transform == rotation_z(0.8) * rotation_z(0.735) * rotation_y(1.570796) *
                                  rotation_x(3.14) * scaling(0.5, 0.5, 0.5) * translation(1., 1., 2.)
    end

    @testset "Shadows on objects can be deactivated" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene.yml")
        sphere = gobjects[2]
        @test !sphere.shadow
    end

    @testset "Objects can be groups and groups have children" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene.yml")
        group = gobjects[3]
        @test group.transform == translation(0., 2., 0.)
        @test group.shapes[1] == Cube()
        group2 = group.shapes[2]
        @test group2.shapes[1] == default_sphere()
    end

    @testset "Define a gobject and load an object file" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene_with_obj_files.yml")
        group = gobjects[1]
        t1 = group.shapes[1]
        t2 = group.shapes[2]
        t3 = group.shapes[3]
        t4 = group.shapes[4]

        smooth_triangle1 = SmoothTriangle(point3D(0., 1., 0.), point3D(-1., 0., 0.), point3D(0., -1., 0.),
                                          vector3D(0., 1., 0.), vector3D(-1., 0., 0.), vector3D(1., 0., 0.))
        smooth_triangle2 = SmoothTriangle(point3D(0., 1., 0.),  point3D(0., -1., 0.), point3D(1., 0., 0.),
                                          vector3D(0., 1., 0.), vector3D(1., 0., 0.), vector3D(1., 0., 0.))

        material = default_material()
        material.color = ColorRGB(1., 0., 0.1)
        material.ambient = 0.1
        material.diffuse = 0.6
        material.specular = 0.3 
        material.shininess = 15

        @test t1.p1 == smooth_triangle1.p1
        @test t1.p2 == smooth_triangle1.p2
        @test t1.p3 == smooth_triangle1.p3

        @test t2.p1 == smooth_triangle2.p1
        @test t2.p2 == smooth_triangle2.p2
        @test t2.p3 == smooth_triangle2.p3

        @test t3 == t1
        @test t4 == t2

        @test t1.material == material
        @test t2.material == material
    end

    @testset "Define a gobject that uses another defined gobject" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene_with_obj_files.yml")
        bbox = gobjects[2]
        t = scaling(0.268, 0.268, 0.268) * translation(0., 0.1217, 0.) * translation(-3.9863, -0.1217, -1.1820) * 
            scaling(3.73335, 2.5845, 1.6283) * translation(1.,1.,1.)
        @test round.(bbox.transform, digits=5) == round.(t, digits=5)
    end 

    @testset "Define groups and children" begin
        camera, lights, gobjects = import_yaml_scene_file("resources/scene_with_obj_files.yml")
        bbox = gobjects[2]
        bbox2 = gobjects[3].shapes[2]
        pedestal = gobjects[3].shapes[3]
        @test bbox.transform == bbox2.transform
        @test bbox !== bbox2
        @test bbox.material !== bbox2.material
        @test gobject_material(bbox2).ambient == 0.
        @test gobject_material(bbox2).diffuse == 0.4
        @test gobject_material(bbox2).transparency == 0.6

        @test gobject_material(pedestal).color == ColorRGB(0.2, 0.2, 0.2)
        @test gobject_material(pedestal).ambient == 0.
        @test gobject_material(pedestal).diffuse == 0.8
        @test gobject_material(pedestal).specular == 0.
        @test gobject_material(pedestal).reflective == 0.2
    end
end
