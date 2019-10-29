using Test
using Aether
using Aether.HomogeneousCoordinates
using Aether.Intersections
using Aether.Shapes
using Aether.Rays
using Aether.BaseGeometricType

@testset "Cones" begin
      @testset "Intersecting a cone with a ray" begin
            shape = Cone()
            input = NamedTuple[]
            ks = (:origin, :direction, :t0, :t1)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, -5.0),
                        vector3D(0.0, 0.0, 1.0),
                        5.0,
                        5.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, -5.0),
                        vector3D(1.0, 1.0, 1.0),
                        8.66025,
                        8.66025,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(1.0, 1.0, -5.0),
                        vector3D(-0.5, -1.0, 1.0),
                        4.55006,
                        49.44994,
                  )),
            )
            for i in input
                  direction = normalize(i.direction)
                  r = Ray(i.origin, direction)
                  xs = local_intersect(shape, r)
                  @test length(xs) == 2
                  @test float_equal(xs[1].t, i.t0)
                  @test float_equal(xs[2].t, i.t1)
            end
      end

      @testset "Intersecting a cone with a ray parallel to one of its halves" begin
            shape = Cone()
            direction = normalize(vector3D(0., 1., 1.))
            r = Ray(point3D(0., 0., -1.), direction)
            xs = local_intersect(shape, r)
            @test length(xs) == 1
            @test float_equal(xs[1].t, 0.35355)
      end

      @testset "Intersecting a cone's end caps" begin
            shape = Cone()
            shape.minimum = -0.5
            shape.maximum = 0.5
            shape.closed = true

            input = NamedTuple[]
            ks = (:origin, :direction, :count)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, -5.0),
                        vector3D(0.0, 1.0, 0.0),
                        0
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, -0.25),
                        vector3D(0.0, 1.0, 1.0),
                        2
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, -0.25),
                        vector3D(0.0, 1.0, 0.0),
                        4
                  )),
            )
            for i in input
                  direction = normalize(i.direction)
                  r = Ray(i.origin, direction)
                  xs = local_intersect(shape, r)
                  @test length(xs) == i.count
            end
      end

      @testset "Computing the normal vector on a cone" begin
            shape = Cone()

            input = NamedTuple[]
            ks = (:point, :normal)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.0, 0.0),
                        vector3D(0.0, 0.0, 0.0)
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(1.0, 1.0, 1.0),
                        vector3D(1.0, -√2, 1.0)
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(-1.0, -1.0, 0.0),
                        vector3D(-1.0, 1.0, 0.)
                  )),
            )
            for i in input
                  n = local_normal_at(shape, i.point)
                  @test float_equal(n, i.normal)
            end
      end
end
