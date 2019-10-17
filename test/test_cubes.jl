using Test
import Aether: float_equal
import Aether.Shapes: Cube, local_intersect, local_normal_at
using Aether.Rays
using Aether.HomogeneousCoordinates

@testset "Cubes" begin
      @testset "A ray intersects a cude" begin
            c = Cube()

            input = NamedTuple[]
            ks = (:origin, :direction, :t1, :t2)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(5.0, 0.5, 0.0),
                        vector3D(-1.0, 0.0, 0.0),
                        4.0,
                        6.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(-5.0, 0.5, 0.0),
                        vector3D(1.0, 0.0, 0.0),
                        4.0,
                        6.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.5, 5.0, 0.0),
                        vector3D(0.0, -1.0, 0.0),
                        4.0,
                        6.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.5, -5.0, 0.0),
                        vector3D(0.0, 1.0, 0.0),
                        4.0,
                        6.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.5, 0.0, 5.0),
                        vector3D(0.0, 0.0, -1.0),
                        4.0,
                        6.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.5, 0.0, -5.0),
                        vector3D(0.0, 0.0, 1.0),
                        4.0,
                        6.0,
                  )),
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0.0, 0.5, 0.0),
                        vector3D(0.0, 0.0, 1.0),
                        -1.0,
                        1.0,
                  )),
            )
            for i in input
                  r = Ray(i.origin, i.direction)
                  xs = local_intersect(c, r)
                  @test xs[1].t == i.t1
                  @test xs[2].t == i.t2
            end
      end

      @testset "A ray misses a cude" begin
            c = Cube()

            input = NamedTuple[]
            ks = (:origin, :direction)
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(-2.0, 0., 0.),
                        vector3D(0.2673, 0.5345, 0.8018)
                        ))
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., -2.0, 0.),
                        vector3D(0.8018, 0.2673, 0.5345)
                        ))
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 0., -2.),
                        vector3D(0.5345, 0.8018, 0.2673)
                        ))
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(2., 0., 2.),
                        vector3D(0., 0., -1.)
                        ))
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(0., 2., 2.),
                        vector3D(0., -1., 0.)
                        ))
            )
            push!(
                  input,
                  NamedTuple{ks}((
                        point3D(2., 2., 0.),
                        vector3D(-1., 0., 0.)
                        ))
            )
            for i in input
                  r = Ray(i.origin, i.direction)
                  xs = local_intersect(c, r)
                  @test length(xs) == 0
            end
      end

      @testset "The normal on the surface of a cube" begin
            c = Cube()

            @test local_normal_at(c, point3D(1., 0.5, -0.8)) == vector3D(1., 0., 0.)
            @test local_normal_at(c, point3D(-1., 0.2, 0.9)) == vector3D(-1., 0., 0.)
            @test local_normal_at(c, point3D(-0.4, 1., -0.1)) == vector3D(0., 1., 0.)
            @test local_normal_at(c, point3D(0.3, -1., -0.7)) == vector3D(0., -1., 0.)
            @test local_normal_at(c, point3D(-0.6, 0.3, 1.)) == vector3D(0., 0., 1.)
            @test local_normal_at(c, point3D(0.4, 0.4, -1.)) == vector3D(0., 0., -1.)
            @test local_normal_at(c, point3D(1., 1., 1.)) == vector3D(1., 0., 0.)
            @test local_normal_at(c, point3D(-1., -1., -1.)) == vector3D(-1., 0., 0.)
      end
end
