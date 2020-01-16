using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.Patterns
using Aether.Shaders
using Aether.Shapes
using Aether.Utils

import Aether: ϵ

using Test

@testset "Materials" begin
    @testset "The default material" begin
        m = default_material()
        @test m.color == ColorRGB(1., 1., 1.)
        @test m.ambient == 0.1
        @test m.diffuse == 0.9
        @test m.specular == 0.9
        @test m.shininess == 200.0
    end

    @testset "Lighting with the eye between the light and the surface" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., -10.), ColorRGB(1., 1., 1.))
        result = lighting(m, default_sphere(), light, position, eyev,
                          normalv, 1.0)
        @test float_equal(result, ColorRGB(1.9, 1.9, 1.9))
    end

    @testset "Lighting with the eye between the light and the surface, eye offset 45°" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., √2 / 2, -√2 / 2)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., -10.), ColorRGB(1., 1., 1.))
        result = lighting(m, default_sphere(), light, position, eyev,
                          normalv, 1.0)
        @test float_equal(result, ColorRGB(1., 1., 1.))
    end

    @testset "Lighting with the eye opposite the surface, light offset 45°" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 10., -10.), ColorRGB(1., 1., 1.))
        result = lighting(m, default_sphere(), light, position, eyev,
                          normalv, 1.0)
        @test float_equal(result, ColorRGB(0.7364, 0.7364, 0.7364))
    end

    @testset "Lighting with the eye in the path of the reflection vector" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., -√2 / 2, -√2 / 2)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 10., -10.), ColorRGB(1., 1., 1.))
        result = lighting(m, default_sphere(), light, position, eyev,
                          normalv, 1.0)
        @test float_equal(result, ColorRGB(1.6364, 1.6364, 1.6364))
    end

    @testset "Lighting with the light behind the surface" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., 10.), ColorRGB(1., 1., 1.))
        result = lighting(m, default_sphere(), light, position, eyev,
                          normalv, 1.0)
        @test float_equal(result, ColorRGB(0.1, 0.1, 0.1))
    end

    @testset "Lighting with the surface in shadow" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., -10.), ColorRGB(1., 1., 1.))
        in_shadow = 0.0
        result = lighting(m, default_sphere(), light,
                 position, eyev, normalv, in_shadow)
        @test float_equal(result, ColorRGB(0.1, 0.1, 0.1))
    end

    @testset "Lighting with a pattern applied" begin
        s = default_sphere()
        m = default_material()
        m.pattern = stripe_pattern(white, black)
        m.ambient = 1.
        m.diffuse = 0.
        m.specular = 0.
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., -10.), white)
        c1 = lighting(m, s, light, point3D(0.9, 0., 0.), eyev, normalv, 1.0)
        c2 = lighting(m, s, light, point3D(1.1, 0., 0.), eyev, normalv, 1.0)
        @test float_equal(c1, white)
        @test float_equal(c2, black)
    end

    @testset "Reflectivity for the default material" begin
        m = default_material()
        @test m.reflective == 0.
    end

    @testset "Transparency and Refractive Index fro the default material" begin
        m = default_material()
        @test m.transparency == 0.
        @test m.refractive_index == 1.0
    end

    @testset "lighting() samples the area light" begin
        corner = point3D(-0.5, -0.5, -5.)
        v1 = vector3D(1., 0., 0.)
        v2 = vector3D(0., 1., 0.)
        light = AreaLight(corner, v1, 2, v2, 2, white)
        light.jitter_by = Generator(0.5)
        shape = default_sphere()
        shape.material.ambient = 0.1
        shape.material.diffuse = 0.9
        shape.material.specular = 0.
        shape.material.color = white
        eye = point3D(0., 0., -5.)

        input = NamedTuple[]
        ks = (:point, :result)
        push!(input, NamedTuple{ks}((point3D(0., 0., -1.), ColorRGB(0.9965, 0.9965, 0.9965))))
        push!(input, NamedTuple{ks}((point3D(0., 0.7071, -0.7071), ColorRGB(0.6232, 0.6232, 0.6232))))

        for i in input
            pt = i.point
            eyev = normalize(eye - pt)
            normalv = vector3D(pt.x, pt.y, pt.z)
            @test_skip lighting(shape.material, shape, light, pt, eyev, normalv, 1.0) == i.result
        end
    end
end
