using Test
using Aether.HomogeneousCoordinates
using Aether.Rays
using Aether.Shapes

@testset "Triangles" begin
    @testset "Constructing a triangle" begin
        p1 = point3D(0.0, 1.0, 0.0)
        p2 = point3D(-1.0, 0.0, 0.0)
        p3 = point3D(1.0, 0.0, 0.0)
        t = Triangle(p1, p2, p3)
        @test t.p1 == p1
        @test t.p2 == p2
        @test t.p3 == p3
        @test t.e1 == vector3D(-1.0, -1.0, 0.0)
        @test t.e2 == vector3D(1.0, -1.0, 0.0)
        @test t.normal == vector3D(0.0, 0.0, -1.0)
    end

    @testset "Finding the normal on a triangle" begin
        t = Triangle(
            point3D(0.0, 1.0, 0.0),
            point3D(-1., 0.0, 0.0),
            point3D(1.0, 0.0, 0.0),
        )
        n1 = local_normal_at(t, point3D(0., 0.5, 0.))
        n2 = local_normal_at(t, point3D(-0.5, 0.75, 0.))
        n3 = local_normal_at(t, point3D(0.5, 0.25, 0.))
        @test n1 == t.normal
        @test n2 == t.normal
        @test n3 == t.normal
    end

    @testset "Intersecting a ray parallel to the triangle" begin
        t = Triangle(
            point3D(0.0, 1.0, 0.0),
            point3D(-1., 0.0, 0.0),
            point3D(1.0, 0.0, 0.0),
        )
        r = Ray(point3D(0., -1., -2.), vector3D(0., 1., 0.))
        xs = local_intersect(t, r)
        @test length(xs) == 0
    end

    @testset "A ray misses the p1-p3 edge" begin
        t = Triangle(
            point3D(0.0, 1.0, 0.0),
            point3D(-1., 0.0, 0.0),
            point3D(1.0, 0.0, 0.0),
        )
        r = Ray(point3D(1., 1., -2.), vector3D(0., 0., 1.))
        xs = local_intersect(t, r)
        @test length(xs) == 0
    end

    @testset "A ray misses the p1-p2 edge" begin
        t = Triangle(
            point3D(0.0, 1.0, 0.0),
            point3D(-1., 0.0, 0.0),
            point3D(1.0, 0.0, 0.0),
        )
        r = Ray(point3D(-1., 1., -2.), vector3D(0., 0., 1.))
        xs = local_intersect(t, r)
        @test length(xs) == 0
    end

    @testset "A ray misses the p2-p3 edge" begin
        t = Triangle(
            point3D(0.0, 1.0, 0.0),
            point3D(-1., 0.0, 0.0),
            point3D(1.0, 0.0, 0.0),
        )
        r = Ray(point3D(0., -1., -2.), vector3D(0., 0., 1.))
        xs = local_intersect(t, r)
        @test length(xs) == 0
    end

    @testset "A ray strikes a triangle" begin
        t = Triangle(
            point3D(0.0, 1.0, 0.0),
            point3D(-1., 0.0, 0.0),
            point3D(1.0, 0.0, 0.0),
        )
        r = Ray(point3D(0., 0.5, -2.), vector3D(0., 0., 1.))
        xs = local_intersect(t, r)
        @test length(xs) == 1
        @test xs[1].t == 2 
    end
end
