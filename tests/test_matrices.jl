using Test
using StaticArrays
using LinearAlgebra

using .RayTracer

@testset "matrix equality" begin
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
   @test A!=C
end

@testset "translations" begin
   @testset "Multiplyng by a translation matrix" begin
      transform = translation(5.0, -3.0, 2.0)
      p = point3D(Float64[-3, 4, 5])
      @test transform * p ≈ point3D(Float64[2,1,7])
   end

   @testset "Multiplyng by the inverse of a translation matrix" begin
      transform = translation(5.0, -3.0, 2.0)
      inverse = inv(transform)
      p = point3D(Float64[-3, 4, 5])
      @test inverse * p ≈ point3D(Float64[-8, 7, 3])
   end
end

@testset "scaling" begin
   @testset "scaling matrix applied to a point" begin
      transform = scaling(2.,3.,4.)
      p = point3D(-4.,6.,8.)
      @test transform * p ≈ point3D(-8., 18., 32.)
   end

   @testset "reflection is scaling by a negative value" begin
      transform = scaling(-1.,1.,1.)
      p = point3D(2.,3.,4.)
      @test transform * p ≈ point3D(-2.,3.,4.)
   end
end
