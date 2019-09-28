using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.Patterns
using Aether.Shaders
using Aether.Spheres

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
        result = lighting(m, light, position, eyev, normalv, false)
        @test isapprox(result, ColorRGB(1.9, 1.9, 1.9), rtol = ϵ)
    end

    @testset "Lighting with the eye between the light and the surface, eye offset 45°" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., √2 / 2, -√2 / 2)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., -10.), ColorRGB(1., 1., 1.))
        result = lighting(m, light, position, eyev, normalv, false)
        @test isapprox(result, ColorRGB(1., 1., 1.), rtol = ϵ)
    end

    @testset "Lighting with the eye opposite the surface, light offset 45°" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 10., -10.), ColorRGB(1., 1., 1.))
        result = lighting(m, light, position, eyev, normalv, false)
        @test isapprox(result, ColorRGB(0.7364, 0.7364, 0.7364), rtol = ϵ)
    end

    @testset "Lighting with the eye in the path of the reflection vector" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., -√2 / 2, -√2 / 2)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 10., -10.), ColorRGB(1., 1., 1.))
        result = lighting(m, light, position, eyev, normalv, false)
        @test isapprox(result, ColorRGB(1.6364, 1.6364, 1.6364), rtol = ϵ)
    end

    @testset "Lighting with the light behind the surface" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., 10.), ColorRGB(1., 1., 1.))
        result = lighting(m, light, position, eyev, normalv, false)
        @test isapprox(result, ColorRGB(0.1, 0.1, 0.1), rtol = ϵ)
    end

    @testset "Lighting with the surface in shadow" begin
        m = default_material()
        position = point3D(0., 0., 0.)
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., -10.), ColorRGB(1., 1., 1.))
        in_shadow = true
        result = lighting(m, light, position, eyev, normalv, in_shadow)
        @test float_equal(result, ColorRGB(0.1, 0.1, 0.1))
    end

    @testset "Lighting with a pattern applied" begin
        m = default_material()
        m.pattern = stripe_pattern(white, black)
        m.ambient = 1.
        m.diffuse = 0.
        m.specular = 0.
        eyev = vector3D(0., 0., -1.)
        normalv = vector3D(0., 0., -1.)
        light = PointLight(point3D(0., 0., -10.), white)
        c1 = lighting(m, light, point3D(0.9, 0., 0.), eyev, normalv, false)
        c2 = lighting(m, light, point3D(1.1, 0., 0.), eyev, normalv, false)
        @test float_equal(c1, white)
        @test float_equal(c2, black)
    end
end
