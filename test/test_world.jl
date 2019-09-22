using Test
using Aether.ColorsModule
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Lights
using Aether.Spheres
using Aether.WorldModule
using Aether.Rays
import Aether: ϵ

@testset "World" begin
    @testset "The default world" begin
        w = default_world()
        light = PointLight(point3D(-10., 10., -10.), ColorRGB(1., 1., 1.))
        @test w.light == light

        s1 = default_sphere()
        s1.material.color = ColorRGB(0.8, 1., 0.6)
        s1.material.diffuse = 0.7
        s1.material.specular = 0.2
        s2 = default_sphere()
        set_transform(s2, scaling(0.5, 0.5, 0.5))
        add_objects(w, s1, s2)
        @test s1 in w.objects
        @test s2 in w.objects
    end

    @testset "Itersect world with a ray" begin
        w = default_world()
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        xs = intersect_world(w, r)
        @test length(xs) == 4
        @test xs[1].t == 4.
        @test xs[2].t == 4.5
        @test xs[3].t == 5.5
        @test xs[4].t == 6.
    end

    @testset "Shading an intersection" begin
        w = default_world()
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        shape = w.objects[1]
        i = Intersection(4., shape)
        comps = prepare_computations(i, r)
        c = shade_hit(w, comps)
        @test isapprox(c, ColorRGB(0.38066, 0.47583, 0.2855), rtol=1.0e-4)
    end

    @testset "Shading an intersection from the inside" begin
        w = default_world()
        w.light = PointLight(point3D(0., 0.25, 0.), ColorRGB(1., 1., 1.))
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        shape = w.objects[2]
        i = Intersection(0.5, shape)
        comps = prepare_computations(i, r)
        c = shade_hit(w, comps)
        @test isapprox(c, ColorRGB(0.90498, 0.90498, 0.90498), rtol=ϵ)
    end

    @testset "The color when a ray misses" begin
        w = default_world()
        r = Ray(point3D(0., 0., -5.), vector3D(0., 1., 0.))
        c = color_at(w, r)
        @test c == ColorRGB(0., 0., 0.)
    end

    @testset "The color when a ray hits" begin
        w = default_world()
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        c = color_at(w, r)
        @test isapprox(c,ColorRGB(0.38066, 0.47583, 0.2855), rtol=1.0e-4)
    end

    @testset "The color when a ray hits" begin
        w = default_world()
        outer = w.objects[1]
        outer.material.ambient = 1.
        inner = w.objects[2]
        inner.material.ambient = 1.
        r = Ray(point3D(0., 0., 0.75), vector3D(0., 0., -1.))
        c = color_at(w, r)
        @test isapprox(c,inner.material.color, rtol=1.0e-4)
    end

    @testset "No shadow when nothing is collinear with point and light" begin
        w = default_world()
        p = point3D(0., 10., 0.)
        @test !is_shadowed(w, p)
    end

    @testset "The shadow when an object is between with point and light" begin
        w = default_world()
        p = point3D(10., -10., 10.)
        @test is_shadowed(w, p)
    end

    @testset "No shadow when an object is behind the light" begin
        w = default_world()
        p = point3D(-20., 20., -20.)
        @test !is_shadowed(w, p)
    end

    @testset "No shadow when an object is behind the point" begin
        w = default_world()
        p = point3D(-2., 2., -2.)
        @test !is_shadowed(w, p)
    end

    @testset "sha_hit is given an intersection in shadow" begin
        w = default_world()
        w.light = PointLight(point3D(0., 0., -10.), ColorRGB(1., 1., 1.))
        s1 = default_sphere()
        add_objects(w, s1)
        s2 = default_sphere()
        set_transform(s2, translation(0., 0., 10.))
        add_objects(w, s2)
        r = Ray(point3D(0., 0., 5.), vector3D(0., 0., 1.))
        i = Intersection(4., s2)
        comps = prepare_computations(i, r)
        c = shade_hit(w, comps)
        @test float_equal(c, ColorRGB(0.1, 0.1, 0.1))
    end
end
