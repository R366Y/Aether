using Test

import Aether.HomogeneousCoordinates: vector3D, point3D, float_equal
import Aether.Planes: Plane, local_intersect, local_normal_at
import Aether.Rays: Ray

@testset "Plane" begin
    @testset "The normal of a plane is constant everywhere" begin
        p = Plane()
        n1 = local_normal_at(p, point3D(0., 0., 0.))
        n2 = local_normal_at(p, point3D(10., 0., 10.))
        n3 = local_normal_at(p, point3D(-5., 0., 150.))
        @test float_equal(n1, vector3D(0., 1., 0.))
        @test float_equal(n2, vector3D(0., 1., 0.))
        @test float_equal(n3, vector3D(0., 1., 0.))
    end

    @testset "Intersect with a ray parallel to the plane" begin
        p = Plane()
        r = Ray(point3D(0., 10., 0.), vector3D(0., 0., 1.))
        xs = local_intersect(p, r)
        @test length(xs) == 0
    end

    @testset "Intersect with a coplanar ray" begin
        p = Plane()
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        xs = local_intersect(p, r)
        @test length(xs) == 0
    end

    @testset "A ray intersecting a plane from above" begin
        p = Plane()
        r = Ray(point3D(0., 1., 0.), vector3D(0., -1., 0.))
        xs = local_intersect(p, r)
        @test length(xs) == 1
        @test xs[1].t == 1.
        @test xs[1].object === p
    end

    @testset "A ray intersecting a plane from below" begin
        p = Plane()
        r = Ray(point3D(0., -1., 0.), vector3D(0., 1., 0.))
        xs = local_intersect(p, r)
        @test length(xs) == 1
        @test xs[1].t == 1.
        @test xs[1].object === p
    end
end
