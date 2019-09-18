using Test
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Spheres
using Aether.WorldModule

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
end
