using Test
using Aether.ColorsModule
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Lights
using Aether.Patterns
using Aether.Shapes
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
        i = Intersection(4., shape)
        comps = prepare_computations(i, r,  Intersection[])
        c = shade_hit(w, comps, 0)
        @test float_equal(c, ColorRGB(0.38066, 0.47583, 0.2855))
    end

    @testset "Shading an intersection from the inside" begin
        w = default_world()
        w.light = PointLight(point3D(0., 0.25, 0.), ColorRGB(1., 1., 1.))
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        shape = w.objects[2]
        i = Intersection(0.5, shape)
        comps = prepare_computations(i, r,  Intersection[])
        c = shade_hit(w, comps, 0)
        @test float_equal(c, ColorRGB(0.90498, 0.90498, 0.90498))
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
        @test float_equal(c,ColorRGB(0.38066, 0.47583, 0.2855))
    end

    @testset "The color when a ray hits" begin
        w = default_world()
        outer = w.objects[1]
        outer.material.ambient = 1.
        inner = w.objects[2]
        inner.material.ambient = 1.
        r = Ray(point3D(0., 0., 0.75), vector3D(0., 0., -1.))
        c = color_at(w, r, 0)
        @test float_equal(c,inner.material.color)
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
        comps = prepare_computations(i, r,  Intersection[])
        c = shade_hit(w, comps, 0)
        @test float_equal(c, ColorRGB(0.1, 0.1, 0.1))
    end

    @testset "The reflected color for a non reflective material" begin
        w = default_world()
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        shape = w.objects[2]
        shape.material.ambient = 1.
        i = Intersection(1., shape)
        comps = prepare_computations(i, r,  Intersection[])
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
        comps = prepare_computations(i, r,  Intersection[])
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
        comps = prepare_computations(i, r,  Intersection[])
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
        comps = prepare_computations(i, r,  Intersection[])
        color = reflected_color(w, comps, 0)
        @test float_equal(color, black)
    end

    @testset "The refracted color with an opaque surface" begin
        w = default_world()
        shape = w.objects[1]
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        xs = Intersection[Intersection(4., shape), Intersection(6., shape)]
        comps = prepare_computations(xs[1], r, xs)
        c = refracted_color(w, comps, 5)
        @test c == black
    end

    @testset "The refracted color at the maximum recursive depth" begin
        w = default_world()
        shape = w.objects[1]
        shape.material.transparency = 1.
        shape.material.refractive_index = 1.5
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        xs = Intersection[Intersection(4., shape), Intersection(6., shape)]
        comps = prepare_computations(xs[1], r, xs)
        c = refracted_color(w, comps, 0)
        @test c == black
    end

    @testset "The refracted color under total internal reflection" begin
        w = default_world()
        shape = w.objects[1]
        shape.material.transparency = 1.
        shape.material.refractive_index = 1.5
        r = Ray(point3D(0., 0., √2/2), vector3D(0., 1., 0.))
        xs = Intersection[Intersection(-√2/2, shape), Intersection(√2/2, shape)]
        # we are inside the sphere, so we need to look at the second
        # intersection xs[2]
        comps = prepare_computations(xs[2], r, xs)
        c = refracted_color(w, comps, 5)
        @test c == black
    end

    @testset "The refracted color with a refracted ray" begin
        w = default_world()
        a = w.objects[1]
        a.material.ambient = 1.
        a.material.pattern = TestPattern()
        b = w.objects[2]
        b.material.transparency = 1.
        b.material.refractive_index = 1.5
        r = Ray(point3D(0., 0., 0.1), vector3D(0., 1., 0.))
        xs = Intersection[Intersection(-0.9899, a), Intersection(-0.4899, b),
                          Intersection(0.4899,b), Intersection(0.9899,a)]
        comps = prepare_computations(xs[3], r, xs)
        c = refracted_color(w, comps, 5)
        @test float_equal(c, ColorRGB(0., 0.99887, 0.04721))
    end

    @testset "shade_hit() with a transparent material" begin
        w = default_world()
        floor = Plane()
        set_transform(floor, translation(0., -1., 0.))
        floor.material.transparency = 0.5
        floor.material.refractive_index = 1.5
        add_objects(w, floor)
        ball = default_sphere()
        ball.material.color = ColorRGB(1., 0., 0.)
        ball.material.ambient = 0.5
        set_transform(ball, translation(0., -3.5, -0.5))
        add_objects(w, ball)
        r = Ray(point3D(0., 0., -3.), vector3D(0., -√2/2, √2/2))
        xs = Intersection[Intersection(√2, floor)]
        comps = prepare_computations(xs[1], r, xs)
        color = shade_hit(w, comps, 5)
        @test float_equal(color, ColorRGB(0.93642, 0.68642, 0.68642))
    end

    @testset "The Schlick approximation under total internal reflection" begin
        shape = glass_sphere()
        r = Ray(point3D(0., 0., √2/2), vector3D(0., 1., 0.))
        xs = Intersection[Intersection(-√2/2, shape), Intersection(√2/2, shape)]
        comps = prepare_computations(xs[2], r, xs)
        reflectance = schlick(comps)
        @test reflectance == 1.
    end

    @testset "The Schlick approximation with a perpendicular viewing angle" begin
        shape = glass_sphere()
        r = Ray(point3D(0., 0., 0.), vector3D(0., 1., 0.))
        xs = Intersection[Intersection(-1., shape), Intersection(1., shape)]
        comps = prepare_computations(xs[2], r, xs)
        reflectance = schlick(comps)
        @test float_equal(reflectance, 0.04)
    end

    @testset "The Schlick approximation with small angle and n2 > n1" begin
        shape = glass_sphere()
        r = Ray(point3D(0., 0.99, -2.), vector3D(0., 0., 1.))
        xs = Intersection[Intersection(1.8589, shape)]
        comps = prepare_computations(xs[1], r, xs)
        reflectance = schlick(comps)
        @test float_equal(reflectance, 0.48873)
    end

    @testset "shade_hit() with a reflective, transparent material" begin
        w = default_world()
        r = Ray(point3D(0., 0., -3.), vector3D(0., -√2/2, √2/2))
        floor = Plane()
        set_transform(floor, translation(0., -1., 0.))
        floor.material.reflective = 0.5
        floor.material.transparency = 0.5
        floor.material.refractive_index = 1.5
        add_objects(w, floor)
        ball = default_sphere()
        ball.material.color = ColorRGB(1., 0., 0.)
        ball.material.ambient = 0.5
        set_transform(ball, translation(0., -3.5, -0.5))
        add_objects(w, ball)
        xs = Intersection[Intersection(√2, floor)]
        comps = prepare_computations(xs[1], r, xs)
        color = shade_hit(w, comps, 5)
        @test float_equal(color, ColorRGB(0.93391, 0.69643, 0.69243))
    end
end
