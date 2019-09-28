using Test

import Aether.ColorsModule: ColorRGB, black, white
import Aether.HomogeneousCoordinates: point3D, vector3D
import Aether.Patterns: Pattern, stripe_pattern, stripe_at

@testset "Patterns" begin
    @testset "Creating a striped pattern" begin
        pattern = stripe_pattern(white, black)
        @test pattern.a == white
        @test pattern.b == black
    end

    @testset "A stripe pattern is constant in y" begin
        pattern = stripe_pattern(white, black)
        @test stripe_at(pattern, point3D(0., 0., 0.)) == white
        @test stripe_at(pattern, point3D(0., 1., 0.)) == white
        @test stripe_at(pattern, point3D(0., 2., 0.)) == white
    end

    @testset "A stripe pattern is constant in z" begin
        pattern = stripe_pattern(white, black)
        @test stripe_at(pattern, point3D(0., 0., 0.)) == white
        @test stripe_at(pattern, point3D(0., 0., 1.)) == white
        @test stripe_at(pattern, point3D(0., 0., 2.)) == white
    end

    @testset "A stripe pattern alternates in x" begin
        pattern = stripe_pattern(white, black)
        @test stripe_at(pattern, point3D(0., 0., 0.)) == white
        @test stripe_at(pattern, point3D(0.9, 0., 0.)) == white
        @test stripe_at(pattern, point3D(1., 0., 0.)) == black
        @test stripe_at(pattern, point3D(-0.1, 0., 0.)) == black
        @test stripe_at(pattern, point3D(-1., 0., 0.)) == black
        @test stripe_at(pattern, point3D(-1.1, 0., 0.)) == white
    end
end
