using Aether.Intersections
using Aether.HomogeneousCoordinates
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Shapes
using Aether.Rays
import Aether.BaseGeometricType: r_intersect, normal_at, set_transform

using Test

import Aether: ϵ

@testset "Spheres" begin
    @testset "A ray intersects a sphere in two points" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1].t ≈ 4.0
        @test xs[2].t ≈ 6.0
    end

    @testset "A ray intersects a sphere at a tangent" begin
        r = Ray(point3D(0., 1., -5.), vector3D(0., 0., 1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1].t ≈ 5.0
        @test xs[2].t ≈ 5.0
    end

    @testset "A ray misses a sphere" begin
        r = Ray(point3D(0., 2., -5.), vector3D(0., 0., 1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 0
    end

    @testset "A ray originates inside a sphere" begin
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1].t ≈ -1.0
        @test xs[2].t ≈ 1.0
    end

    @testset "A sphere is behind the ray" begin
        r = Ray(point3D(0., 0., 5.), vector3D(0., 0., 1.))
        s = default_sphere()
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1].t ≈ -6.0
        @test xs[2].t ≈ -4.0
    end

    @testset "A sphere default transformation" begin
        s = default_sphere()
        @test s.transform == identity_matrix(Float64)
    end

    @testset "Intersecting a scaled sphere with a ray" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        s = default_sphere()
        set_transform(s, scaling(2., 2., 2.))
        xs = r_intersect(s, r)
        @test length(xs) == 2
        @test xs[1].t ≈ 3.
        @test xs[2].t ≈ 7.
    end

    @testset "Intersect a translated sphere with a ray" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        s = default_sphere()
        set_transform(s, translation(5., 0., 0.))
        xs = r_intersect(s, r)
        @test length(xs) == 0
    end

    @testset "A sphere has a default material" begin
        s = default_sphere()
        m = s.material
        @test compare_materials(m, default_material())
    end

    @testset "A sphere may be assigned a material" begin
        s = default_sphere()
        m = default_material()
        m.ambient = 1.
        s.material = m
        @test compare_materials(s.material, m)
    end
end

@testset "Sphere Normal" begin
    @testset "The normal on a sphere at a point on the x y z axis" begin
        s = default_sphere()
        n = normal_at(s, point3D(1., 0., 0.))
        @test n == vector3D(1., 0., 0.)

        n = normal_at(s, point3D(0., 1., 0.))
        @test n == vector3D(0., 1., 0.)

        n = normal_at(s, point3D(0., 0., 1.))
        @test n == vector3D(0., 0., 1.)
    end

    @testset "Computing the normal on a translated sphere" begin
        s = default_sphere()
        set_transform(s, translation(0., 1., 0.))
        n = normal_at(s, point3D(0., 1.70711, -0.70711))
        @test float_equal(n, vector3D(0., 0.70711, -0.70711))
    end

    @testset "Computing the normal on a transformed sphere" begin
        s = default_sphere()
        m = scaling(1., 0.5, 1.) * rotation_z(pi \ 5)
        set_transform(s, m)
        n = normal_at(s, point3D(0., √2 / 2, -√2 / 2))
        @test float_equal(n, vector3D(0., 0.97014, -0.24254))
    end

    @testset "A helper for producing a sphere with a glassy material" begin
        s = glass_sphere()
        @test s.transform == identity_matrix(Float64)
        @test s.material.transparency == 1.
        @test s.material.refractive_index == 1.5
    end
end
