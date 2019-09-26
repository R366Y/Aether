using Test

import Aether.BaseGeometricType: set_transform, normal_at
import Aether.HomogeneousCoordinates: point3D, vector3D, float_equal
import Aether.Materials: Material, default_material
import Aether.MatrixTransformations: identity_matrix, translation, scaling,
                                     rotation_z
import Aether.Rays: Ray
import Aether.Shapes: TestShape

@testset "Shapes" begin
    @testset "The default transformation" begin
        s = TestShape()
        @test s.transform == identity_matrix(Float64)
    end

    @testset "Assigning a transformation" begin
        s = TestShape()
        set_transform(s, translation(2., 3., 4.))
        @test s.transform == translation(2., 3., 4.)
        @test s.inverse == inv(translation(2., 3., 4.))
    end

    @testset "The default material" begin
        s = TestShape()
        @test s.material == default_material()
    end

    @testset "Assigning a material" begin
        s = TestShape()
        m = default_material()
        m.ambient = 1.
        s.material = m
        @test s.material == m
    end

    @testset "Intersecting a scaled shape with a ray" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        s = TestShape()
        set_transform(s, scaling(2., 2., 2.))
        xs = r_intersect(s, r)
        @test float_equal(s.saved_ray.origin, point3D(0., 0., -2.5))
        @test float_equal(s.saved_ray.direction, vector3D(0., 0., 0.5))
    end

    @testset "Intersecting a translated shape with a ray" begin
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        s = TestShape()
        set_transform(s, translation(5., 0., 0.))
        xs = r_intersect(s, r)
        @test float_equal(s.saved_ray.origin, point3D(-5., 0., -5.))
        @test float_equal(s.saved_ray.direction, vector3D(0., 0., 1.))
    end

    @testset "Computing the normal on a translated shape" begin
        s = TestShape()
        set_transform(s, translation(0., 1., 0.))
        n = normal_at(s, point3D(0., 1.70711, -0.70711))
        @test float_equal(n, vector3D(0., 0.70711, -0.70711))
    end

    @testset "Computing the normal on a transformed shape" begin
        s = TestShape()
        m = scaling(1., 0.5, 1.) * rotation_z(π/5)
        set_transform(s, m)
        n = normal_at(s, point3D(0., √2/2, -√2/2))
        @test float_equal(n, vector3D(0., 0.97014, -0.24254))
    end
end
