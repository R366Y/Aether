using Test
using Aether.ComputationsModule
using Aether.HomogeneousCoordinates
using Aether.BaseGeometricType
using Aether.MatrixTransformations
using Aether.Shapes
using Aether.Rays

import Aether: ϵ

@testset "Intersections" begin
    @testset "Intersection encapsulates t and object" begin
        s = default_sphere()
        i = Intersection(3.5, s)
        @test i.t == 3.5
        @test i.gobject == s
    end

    @testset "Hit when all intersections have positive t" begin
        s = default_sphere()
        i1 = Intersection(1., s)
        i2 = Intersection(2., s)
        i = hit([i2,i1])
        @test i === i1
    end

    @testset "Hit when all intersections have negative t" begin
        s = default_sphere()
        i1 = Intersection(-1., s)
        i2 = Intersection(-2., s)
        i = hit([i2,i1])
        @test i === nothing
    end

    @testset "Hit one intersection have negative t" begin
        s = default_sphere()
        i1 = Intersection(-1., s)
        i = hit([i1])
        @test i === nothing
    end

    @testset "Hit is always the lowest nonnegative intersection" begin
        s = default_sphere()
        i1 = Intersection(5., s)
        i2 = Intersection(7., s)
        i3 = Intersection(-3., s)
        i4 = Intersection(2., s)
        i = hit([i2,i1,i4,i3])
        @test i === i4
    end

    @testset "And intersection can encapsulate 'u' and 'v'" begin
        s = Triangle(point3D(0., 1., 0.), point3D(-1., 0., 0.), point3D(1., 0., 0.))
        i = Intersection(3.5, s, 0.2, 0.4)
        @test i.u == 0.2
        @test i.v == 0.4
    end
end

@testset "Reflecting vectors" begin
    @testset "Reflecting a vector approaching at 45°" begin
        v = vector3D(1., -1., 0.)
        n = vector3D(0., 1., 0.)
        r = reflect(v, n)
        @test float_equal(r, vector3D(1., 1., 0.))
    end
    @testset "Reflecting a vector off a slanted surface" begin
        v = vector3D(0., -1., 0.)
        n = vector3D(√2/2, √2/2, 0.)
        r = reflect(v, n)
        @test float_equal(r,vector3D(1., 0., 0.))
    end
end

@testset "Computations" begin
    @testset "Precomputing the test of an intersection" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        shape = default_sphere()
        i = Intersection(4., shape)
        comps = prepare_computations(i, r, Intersection[])
        @test comps.t == i.t
        @test comps.gobject == shape
        @test comps.point == point3D(0., 0., -1.)
        @test comps.eyev == vector3D(0., 0., -1.)
        @test comps.normalv == vector3D(0., 0., -1.)
    end

    @testset "The hit when an intersection occurs on the outside" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        shape = default_sphere()
        i = Intersection(4., shape)
        comps = prepare_computations(i, r,  Intersection[])
        @test !comps.inside
    end

    @testset "The hit when an intersection occurs on the inside" begin
        r = Ray(point3D(0., 0., 0.), vector3D(0., 0., 1.))
        shape = default_sphere()
        i = Intersection(1., shape)
        comps = prepare_computations(i, r,  Intersection[])
        @test comps.inside
        @test comps.point == point3D(0., 0., 1.)
        @test comps.eyev == vector3D(0., 0., -1.)
        # normal is inverted becaus it is inside hit
        @test comps.normalv == vector3D(0., 0., -1.)
    end

    @testset "Precomputing the reflection vector" begin
        shape = Plane()
        r = Ray(point3D(0., 1., -1.), vector3D(0., -√2/2, √2/2))
        i = Intersection(√2, shape)
        comps = prepare_computations(i, r,  Intersection[])
        @test float_equal(comps.reflectv, vector3D(0., √2/2, √2/2))
    end

    @testset "Finding n1 and n2 at various intersections" begin
        a = glass_sphere()
        set_transform(a, scaling(2., 2., 2.))
        a.material.refractive_index = 1.5
        b = glass_sphere()
        set_transform(b, translation(0., 0., -0.25))
        b.material.refractive_index = 2.0
        c = glass_sphere()
        set_transform(c, translation(0., 0., 0.25))
        c.material.refractive_index = 2.5
        r = Ray(point3D(0., 0., -4.), vector3D(0., 0., 1.))
        xs = Intersection[Intersection(2., a), Intersection(2.75, b),
                         Intersection(3.25, c), Intersection(4.75, b),
                         Intersection(5.25, c), Intersection(6., a)]
        result = Dict()
        for (index,i) in enumerate(xs)
            comps = prepare_computations(xs[index], r, xs)
            push!(result, index => [comps.n1, comps.n2])
        end
        @test result[1] == [1.0, 1.5]
        @test result[2] == [1.5, 2.]
        @test result[3] == [2., 2.5]
        @test result[4] == [2.5, 2.5]
        @test result[5] == [2.5, 1.5]
        @test result[6] == [1.5, 1.]
    end

    @testset "The under point is offset below the surface" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        shape = glass_sphere()
        set_transform(shape, translation(0., 0., 1.))
        i = Intersection(5., shape)
        xs = Intersection[i]
        comps = prepare_computations(i, r, xs)
        @test comps.under_point.z > ϵ / 2
        @test comps.point.z < comps.under_point.z
    end
end
