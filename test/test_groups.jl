using Test
using Aether
using Aether.BaseGeometricType
using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
using Aether.Shapes

@testset "Groups" begin
    @testset "Creating a new group" begin
        g = Group()
        @test g.transform == identity_matrix(Float64)
        @test length(g.shapes) == 0
    end

    @testset "A shape has a parent attribute" begin
        s = TestShape()
        @test isnothing(s.parent)
    end

    @testset "Adding a child to a group" begin
        g = Group()
        s = TestShape()
        add_child(g, s)
        @test length(g.shapes) > 0
        @test s ∈ g.shapes
        @test get_parent_group(s) === g
    end

    @testset "Intersecting a ray with an empty group" begin
        g = Group()
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        xs = local_intersect(g, r)
        @test length(xs) == 0
    end

    @testset "Intersecting a ray with a nonempty group" begin
        g = Group()
        s1 = default_sphere()
        s2 = default_sphere()
        set_transform(s2, translation(0., 0., -3.))
        s3 = default_sphere()
        set_transform(s3, translation(5., 0., 0.))
        add_child(g, s1)
        add_child(g, s2)
        add_child(g, s3)
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        xs = local_intersect(g, r)
        @test length(xs) == 4
        @test xs[1].gobject === s2
        @test xs[2].gobject === s2
        @test xs[3].gobject === s1
        @test xs[4].gobject === s1
    end

    @testset "Intersecting a transformed group" begin
        g = Group()
        set_transform(g, scaling(2., 2., 2.))
        s = default_sphere()
        set_transform(s, translation(5., 0., 0.))
        add_child(g, s)
        r = Ray(point3D(10., 0., -10.), vector3D(0., 0., 1.))
        xs = r_intersect(g, r)
        @test length(xs) == 2
    end

    @testset "Converting a point from world to object space" begin
        g1 = Group()
        set_transform(g1, rotation_y(π/2))
        g2 = Group()
        set_transform(g2, scaling(2., 2., 2.))
        add_child(g1, g2)
        s = default_sphere()
        set_transform(s, translation(5., 0., 0.))
        add_child(g2, s)
        p = world_to_object(s, point3D(-2., 0., -10.))
        @test float_equal(p, point3D(0., 0., -1.))
    end

    @testset "Converting normal from object to world space" begin
        g1 = Group()
        set_transform(g1, rotation_y(π/2))
        g2 = Group()
        set_transform(g2, scaling(1., 2., 3.))
        add_child(g1, g2)
        s = default_sphere()
        set_transform(s, translation(5., 0., 0.))
        add_child(g2, s)
        n = normal_to_world(s, vector3D(√3/3, √3/3, √3/3))
        @test float_equal(n, vector3D(0.28571, 0.42857, -0.85714))
    end

    @testset "Finding the normal on a child object" begin
        g1 = Group()
        set_transform(g1, rotation_y(π/2))
        g2 = Group()
        set_transform(g2, scaling(1., 2., 3.))
        add_child(g1, g2)
        s = default_sphere()
        set_transform(s, translation(5., 0., 0.))
        add_child(g2, s)
        n = normal_at(s, point3D(1.7321, 1.1547, -5.5774))
        @test float_equal(n, vector3D(0.28570, 0.42854, -0.85716))
    end
end
