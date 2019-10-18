using Test
using Aether
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Shapes
using Aether.Rays

@testset "Cylinder" begin

      @testset "A ray strikes a cylinder" begin
            cyl = Cylinder()
            input = NamedTuple[]
            ks = (:origin, :direction, :t0, :t1)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(1.0, 0.0, -5.0),
                        vector3D(0.0, 0.0, 1.0),
                        5.0,
                        5.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, -5.0),
                        vector3D(0.0, 0.0, 1.0),
                        4.0,
                        6.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.5, 0.0, -5.0),
                        vector3D(0.1, 1.0, 1.0),
                        6.80798,
                        7.08872,
                  )),
            )
            for i in input
                  direction = normalize(i.direction)
                  r = Ray(i.origin, direction)
                  xs = local_intersect(cyl, r)
                  @test length(xs) == 2
                  @test float_equal(xs[1].t, i.t0)
                  @test float_equal(xs[2].t, i.t1)
            end
      end

      @testset "A ray misses a cylinder" begin
            cyl = Cylinder()
            input = NamedTuple[]
            ks = (:origin, :direction)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(1.0, 0.0, 0.0),
                        vector3D(0.0, 1.0, 0.0),
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, 0.0),
                        vector3D(0.0, 1.0, 0.0),
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, -5.0),
                        vector3D(1.0, 1.0, 1.0),
                  )),
            )
            for i in input
                  direction = normalize(i.direction)
                  r = Ray(i.origin, direction)
                  xs = local_intersect(cyl, r)
                  @test length(xs) == 0
            end
      end

      @testset "Normal vector on a cylinder" begin
            cyl = Cylinder()

            input = NamedTuple[]
            ks = (:point, :normal)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(1.0, 0.0, 0.0),
                        vector3D(1.0, 0.0, 0.0),
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 5.0, -1.0),
                        vector3D(0.0, 0.0, -1.0),
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, -2.0, 1.0),
                        vector3D(0.0, 0.0, 1.0),
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(-1.0, 1.0, 0.0),
                        vector3D(-1.0, 0.0, 0.0),
                  )),
            )
            for i in input
                  n = local_normal_at(cyl, i.point)
                  @test float_equal(n, i.normal)
            end
      end

      @testset "The default minimum and maximum for a cylinder" begin
            cyl = Cylinder()
            @test cyl.minimum == -Inf
            @test cyl.maximum == Inf
      end

      @testset "Intersecting a constrained cylinder" begin
            cyl = Cylinder()
            cyl.minimum = 1
            cyl.maximum = 2

            input = NamedTuple[]
            ks = (:point, :direction, :count)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 1.5, 0.),
                        vector3D(0.1, 1., 0.),
                        0
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 3., -5.),
                        vector3D(0., 0., 1.),
                        0
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 0., -5.),
                        vector3D(0., 0., 1.),
                        0
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 2., -5.),
                        vector3D(0., 0., 1.),
                        0
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 1., -5.),
                        vector3D(0., 0., 1.),
                        0
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 1.5, -2.),
                        vector3D(0., 0., 1.),
                        2
                  )),
            )
            for i in input
                  direction = normalize(i.direction)
                  r = Ray(i.point, direction)
                  xs = local_intersect(cyl, r)
                  @test length(xs) == i.count
            end
      end

      @testset "The default closed value for a cylinder" begin
            cyl = Cylinder()
            @test cyl.closed == false
      end

      @testset "Intersecting the caps of a closed cylinder" begin
            cyl = Cylinder()
            cyl.minimum = 1
            cyl.maximum = 2
            cyl.closed = true

            input = NamedTuple[]
            ks = (:point, :direction, :count)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 3., 0.),
                        vector3D(0., -1., 0.),
                        2
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 3., -2.),
                        vector3D(0., -1., 2.),
                        2
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 4., -2.),
                        vector3D(0., -1., 1.),
                        2
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 0., -2.),
                        vector3D(0., 1., 2.),
                        2
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., -1., -2.),
                        vector3D(0., 1., 1.),
                        2
                  )),
            )
            for i in input
                  direction = normalize(i.direction)
                  r = Ray(i.point, direction)
                  xs = local_intersect(cyl, r)
                  @test length(xs) == i.count
            end
      end

      @testset "The normal vector on a cylinder's end cap" begin
            cyl = Cylinder()
            cyl.minimum = 1
            cyl.maximum = 2
            cyl.closed = true

            input = NamedTuple[]
            ks = (:point, :normal)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 1., 0.),
                        vector3D(0., -1., 0.)
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.5, 1., 0.),
                        vector3D(0., -1., 0.)
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 1., 0.5),
                        vector3D(0., -1., 0.)
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 2., 0.),
                        vector3D(0., 1., 0.)
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.5, 2., 0.),
                        vector3D(0., 1., 0.)
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 2., 0.5),
                        vector3D(0., 1., 0.)
                  )),
            )
            for i in input
                  n = local_normal_at(cyl, i.point)
                  @test n == i.normal
            end
      end
end
