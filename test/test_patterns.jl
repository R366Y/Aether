using Test

import Aether.ColorsModule: ColorRGB, black, white
import Aether.HomogeneousCoordinates: point3D, vector3D
import Aether.MatrixTransformations: scaling, translation, identity_matrix
import Aether.Patterns: StripePattern, TestPattern, stripe_pattern, pattern_at,
                        pattern_at_shape, set_pattern_transform,
                        GradientPattern, RingPattern, CheckerPattern
import Aether.Shapes: default_sphere, set_transform

@testset "Patterns" begin
    @testset "Creating a striped pattern" begin
        pattern = StripePattern(white, black)
        @test pattern.a == white
        @test pattern.b == black
    end

    @testset "A stripe pattern is constant in y" begin
        pattern = stripe_pattern(white, black)
        @test pattern_at(pattern, point3D(0., 0., 0.)) == white
        @test pattern_at(pattern, point3D(0., 1., 0.)) == white
        @test pattern_at(pattern, point3D(0., 2., 0.)) == white
    end

    @testset "A stripe pattern is constant in z" begin
        pattern = stripe_pattern(white, black)
        @test pattern_at(pattern, point3D(0., 0., 0.)) == white
        @test pattern_at(pattern, point3D(0., 0., 1.)) == white
        @test pattern_at(pattern, point3D(0., 0., 2.)) == white
    end

    @testset "A stripe pattern alternates in x" begin
        pattern = stripe_pattern(white, black)
        @test pattern_at(pattern, point3D(0., 0., 0.)) == white
        @test pattern_at(pattern, point3D(0.9, 0., 0.)) == white
        @test pattern_at(pattern, point3D(1., 0., 0.)) == black
        @test pattern_at(pattern, point3D(-0.1, 0., 0.)) == black
        @test pattern_at(pattern, point3D(-1., 0., 0.)) == black
        @test pattern_at(pattern, point3D(-1.1, 0., 0.)) == white
    end

    @testset "Stripes with an object transformation" begin
        object = default_sphere()
        set_transform(object, scaling(2., 2., 2.))
        pattern = stripe_pattern(white, black)
        c = pattern_at_shape(pattern, object, point3D(1.5, 0., 0.))
        @test c == white
    end

    @testset "Stripes with a pattern transformation" begin
        object = default_sphere()
        pattern = stripe_pattern(white, black)
        set_pattern_transform(pattern, scaling(2., 2., 2.))
        c = pattern_at_shape(pattern, object, point3D(1.5, 0., 0.))
        @test c == white
    end

    @testset "Stripes with an object and pattern transformation" begin
        object = default_sphere()
        set_transform(object, scaling(2., 2., 2.))
        pattern = stripe_pattern(white, black)
        set_pattern_transform(pattern, translation(0.5, 0., 0.))
        c = pattern_at_shape(pattern, object, point3D(2.5, 0., 0.))
        @test c == white
    end

    @testset "The default pattern transformation" begin
        pattern = TestPattern()
        @test pattern.transform == identity_matrix(Float64)
    end

    @testset "Assigning a transformation" begin
        pattern = TestPattern()
        set_pattern_transform(pattern, translation(1.,2.,3.))
        @test pattern.transform == translation(1.,2.,3.)
        @test pattern.inverse == inv(translation(1.,2.,3.))
    end

    @testset "A pattern with an object transformation" begin
        shape = default_sphere()
        set_transform(shape, scaling(2., 2., 2.))
        pattern = TestPattern()
        c = pattern_at_shape(pattern, shape, point3D(2., 3., 4.))
        @test c == ColorRGB(1., 1.5, 2.)
    end

    @testset "A pattern with a pattern transformation" begin
        shape = default_sphere()
        pattern = TestPattern()
        set_pattern_transform(pattern, scaling(2., 2., 2.))
        c = pattern_at_shape(pattern, shape, point3D(2., 3., 4.))
        @test c == ColorRGB(1., 1.5, 2.)
    end

    @testset "A pattern with both an object and a pattern transformation" begin
        shape = default_sphere()
        set_transform(shape, scaling(2., 2., 2.))
        pattern = TestPattern()
        set_pattern_transform(pattern, translation(0.5, 1., 1.5))
        c = pattern_at_shape(pattern, shape, point3D(2.5, 3., 3.5))
        @test c == ColorRGB(0.75, 0.5, 0.25)
    end

    @testset "A gradient linearly interpolates between colors" begin
        pattern = GradientPattern(white, black)
        @test pattern_at(pattern, point3D(0.,0.,0.)) == white
        @test pattern_at(pattern, point3D(0.25,0.,0.)) == ColorRGB(0.75, 0.75, 0.75)
        @test pattern_at(pattern, point3D(0.5,0.,0.)) == ColorRGB(0.5, 0.5, 0.5)
        @test pattern_at(pattern, point3D(0.75,0.,0.)) == ColorRGB(0.25, 0.25, 0.25)
    end

    @testset "A ring should extend in both x and z" begin
        pattern = RingPattern(white, black)
        @test pattern_at(pattern, point3D(0.,0.,0.)) == white
        @test pattern_at(pattern, point3D(1.,0.,0.)) == black
        @test pattern_at(pattern, point3D(0.,0.,1.)) == black
        @test pattern_at(pattern, point3D(0.708,0.,0.708)) == black
    end

    @testset "Checkers should repeat in x" begin
        pattern = CheckerPattern(white, black)
        @test pattern_at(pattern, point3D(0., 0., 0.)) == white
        @test pattern_at(pattern, point3D(0.99, 0., 0.)) == white
        @test pattern_at(pattern, point3D(1.01, 0., 0.)) == black
    end

    @testset "Checkers should repeat in y" begin
        pattern = CheckerPattern(white, black)
        @test pattern_at(pattern, point3D(0., 0., 0.)) == white
        @test pattern_at(pattern, point3D(0., 0.99, 0.)) == white
        @test pattern_at(pattern, point3D(0., 1.01, 0.)) == black
    end

    @testset "Checkers should repeat in z" begin
        pattern = CheckerPattern(white, black)
        @test pattern_at(pattern, point3D(0., 0., 0.)) == white
        @test pattern_at(pattern, point3D(0., 0., 0.99)) == white
        @test pattern_at(pattern, point3D(0., 0., 1.01)) == black
    end
end
