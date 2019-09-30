using Test
using Aether.ColorsModule
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Lights
using Aether.Planes
using Aether.Spheres
using Aether.WorldModule
using Aether.Rays
import Aether: ϵ
import Aether.BaseGeometricType: set_transform

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
        i = Intersection{Sphere}(4., shape)
        comps = prepare_computations(i, r)
        c = shade_hit(w, comps, 0)
        @test isapprox(c, ColorRGB(0.38066, 0.47583, 0.2855), rtol=1.0e-4)
    end

    @testset "Shading an intersection from the inside" begin
        w = default_world()
        w.light = PointLight(point3D(0., 0.25, 0.), ColorRGB(1., 1., 1.))
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        shape = w.objects[2]
        i = Intersection{Sphere}(0.5, shape)
        comps = prepare_computations(i, r)
        c = shade_hit(w, comps, 0)
        @test isapprox(c, ColorRGB(0.90498, 0.90498, 0.90498), rtol=ϵ)
    end

    @testset "The color when a ray misses" begin
        w = default_world()
        r = Ray(point3D(0., 0., -5.), vector3D(0., 1., 0.))
        c = color_at(w, r, 0)
        @test c == ColorRGB(0., 0., 0.)
    end

    @testset "The color when a ray hits" begin
        w = default_world()
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        c = color_at(w, r, 0)
        @test isapprox(c,ColorRGB(0.38066, 0.47583, 0.2855), rtol=1.0e-4)
    end

    @testset "The color when a ray hits" begin
        w = default_world()
        outer = w.objects[1]
        outer.material.ambient = 1.
        inner = w.objects[2]
        inner.material.ambient = 1.
        r = Ray(point3D(0., 0., 0.75), vector3D(0., 0., -1.))
        c = color_at(w, r, 0)
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

    @testset "shade_hit is given an intersection in shadow" begin
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
        c = shade_hit(w, comps, 0)
        @test float_equal(c, ColorRGB(0.1, 0.1, 0.1))
    end

    @testset "The reflected color for a non reflective material" begin
        w = default_world()
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        shape = w.objects[2]
        shape.material.ambient = 1.
        i = Intersection(1., shape)
        comps = prepare_computations(i, r)
        color = reflected_color(w, comps, 0)
        @test float_equal(color, black)
    end

    @testset "The reflected color for a reflective material" begin
        w = default_world()
        shape = Plane()
        shape.material.reflective = 0.5
        set_transform(shape, translation(0., -1., 0.))
        add_objects(w, shape)
        r = Ray(point3D(0., 0., -3.), vector3D(0., -√2/2, √2/2))
        i = Intersection(√2, shape)
        comps = prepare_computations(i, r)
        color = reflected_color(w, comps, 1)
        @test float_equal(color, ColorRGB(0.19033, 0.23791, 0.14274))
    end

    @testset "shade_hit() with a reflective material" begin
        w = default_world()
        shape = Plane()
        shape.material.reflective = 0.5
        set_transform(shape, translation(0., -1., 0.))
        add_objects(w, shape)
        r = Ray(point3D(0., 0., -3.), vector3D(0., -√2/2, √2/2))
        i = Intersection(√2, shape)
        comps = prepare_computations(i, r)
        color = shade_hit(w, comps, 1)
        @test float_equal(color, ColorRGB(0.87675, 0.92434, 0.82917))
    end

    @testset "color_at() with mutually reflective surfaces" begin
        w = default_world()
        w.light = PointLight(point3D(0., 0., 0.), white)
        lower = Plane()
        lower.material.reflective = 1.
        set_transform(lower, translation(0., -1., 0.))
        add_objects(w, lower)
        upper = Plane()
        upper.material.reflective = 1.
        set_transform(upper, translation(0., 1., 0.))
        add_objects(w, upper)
        r = Ray(point3D(0., 0., 0.), vector3D(0., 1., 0.))
        color_at(w, r, 0)
    end

    @testset "The reflected color at the maximum recursive depth" begin
        w = default_world()
        shape = Plane()
        shape.material.reflective = 0.5
        set_transform(shape, translation(0., -1., 0.))
        add_objects(w, shape)
        r = Ray(point3D(0., 0., -3.), vector3D(0., -√2/2, √2/2))
        i = Intersection(√2, shape)
        comps = prepare_computations(i, r)
        color = reflected_color(w, comps, 0)
        @test float_equal(color, black)
    end
end
