using Test
using StaticArrays
using LinearAlgebra

using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
import Aether: ϵ, float_equal

@testset "Matrix equality" begin
   A = [
      1 2 3 4;
      5 6 7 8;
      9 8 7 6;
      5 4 3 2
   ]
   B = copy(A)
   C = [
      2 3 4 5;
      6 7 8 9;
      8 7 6 5;
      4 3 2 1
   ]
   @test A == B
   @test A != C
end

@testset "Translation Matrix" begin
   @testset "Multiplyng by a translation matrix" begin
      transform = translation(5.0, -3.0, 2.0)
      p = point3D(Float64[-3, 4, 5])
      @test transform * p ≈ point3D(Float64[2, 1, 7])
   end

   @testset "Multiplyng by the inverse of a translation matrix" begin
      transform = translation(5.0, -3.0, 2.0)
      inverse = inv(transform)
      p = point3D(Float64[-3, 4, 5])
      @test inverse * p ≈ point3D(Float64[-8, 7, 3])
   end
end

@testset "Scaling Matrix" begin
   @testset "scaling matrix applied to a point" begin
      transform = scaling(2., 3., 4.)
      p = point3D(-4., 6., 8.)
      @test transform * p ≈ point3D(-8., 18., 32.)
   end

   @testset "Multiplyng by the inverse of a scaling matrix" begin
      transform = scaling(2., 3., 4.)
      v = vector3D(-4., 6., 8.)
      inverse = inv(transform)
      @test inverse * v ≈ vector3D(-2., 2., 2.)
   end

   @testset "reflection is scaling by a negative value" begin
      transform = scaling(-1., 1., 1.)
      p = point3D(2., 3., 4.)
      @test transform * p ≈ point3D(-2., 3., 4.)
   end
end

@testset "Rotation Matrix" begin
   @testset "Rotating a point around the x axis" begin
      p = point3D(0., 1., 0.)
      half_quarter = rotation_x(π / 4)
      full_quarter = rotation_x(π / 2)
      @test float_equal(half_quarter * p, point3D(0., √2/2, √2/2))
      @test float_equal(full_quarter * p, point3D(0., 0., 1.))
   end

   @testset "Rotating a point around the y axis" begin
      p = point3D(0., 0., 1.)
      half_quarter = rotation_y(π / 4)
      full_quarter = rotation_y(π / 2)
      @test float_equal(half_quarter * p,point3D(√2/2, 0., √2/2))
      @test float_equal(full_quarter * p, point3D(1., 0., 0.))
   end

   @testset "Rotating a pont around z axis" begin
      p = point3D(0., 1., 0.)
      half_quarter = rotation_z(π / 4)
      full_quarter = rotation_z(π / 2)
      @test float_equal(half_quarter * p, point3D(-√2/2, √2/2, 0.))
      @test float_equal(full_quarter * p, point3D(-1., 0., 0.))
   end
end
