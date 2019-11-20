using Test
using Aether
using Aether.HomogeneousCoordinates

@testset "OBJ file reader" begin
    @testset "Ignoring unrecognized lines" begin
        obj_file = parse_obj_file("resources/gibberish.obj")
        @test length(obj_file.vertices) == 0
    end

    @testset "Vertex records" begin
        obj_file = parse_obj_file("resources/only_vertices.obj")
        @test obj_file.vertices[1] == point3D(-1., 1., 0.)
        @test obj_file.vertices[2] == point3D(-1., 0.5, 0.)
        @test obj_file.vertices[3] == point3D(1., 0., 0.)
        @test obj_file.vertices[4] == point3D(1., 1., 0.)
    end
    @testset "Parsing triangle faces" begin
        obj_file = parse_obj_file("resources/vertices_and_faces.obj")
        g = obj_file.default_group
        t1 = g.shapes[1]
        t2 = g.shapes[2]
        @test t1.p1 == obj_file.vertices[1]
        @test t1.p2 == obj_file.vertices[2]
        @test t1.p3 == obj_file.vertices[3]

        @test t2.p1 == obj_file.vertices[1]
        @test t2.p2 == obj_file.vertices[3]
        @test t2.p3 == obj_file.vertices[4]
    end

    @testset "Triangulating polygons" begin
        parser = parse_obj_file("resources/polygon.obj")
        g = parser.default_group
        t1 = g.shapes[1]
        t2 = g.shapes[2]
        t3 = g.shapes[3]
        @test t1.p1 == parser.vertices[1]
        @test t1.p2 == parser.vertices[2]
        @test t1.p3 == parser.vertices[3]

        @test t2.p1 == parser.vertices[1]
        @test t2.p2 == parser.vertices[3]
        @test t2.p3 == parser.vertices[4]

        @test t3.p1 == parser.vertices[1]
        @test t3.p2 == parser.vertices[4]
        @test t3.p3 == parser.vertices[5]
    end

    @testset "Triangles in groups" begin
        parser = parse_obj_file("resources/triangles_named_groups.obj")
        g1 = parser.named_groups["FirstGroup"]
        g2 = parser.named_groups["SecondGroup"]
        t1 = g1.shapes[1]
        t2 = g2.shapes[1]
        @test t1.p1 == parser.vertices[1]
        @test t1.p2 == parser.vertices[2]
        @test t1.p3 == parser.vertices[3]
        @test t2.p1 == parser.vertices[1]
        @test t2.p2 == parser.vertices[3]
        @test t2.p3 == parser.vertices[4]
    end

    @testset "Converting an OBJ file to a group" begin
        parser = parse_obj_file("resources/triangles_named_groups.obj")
        g = obj_to_group(parser)
        g1 = parser.named_groups["FirstGroup"]
        g2 = parser.named_groups["SecondGroup"]
        @test g1 in g.shapes
        @test g2 in g.shapes
    end
end
