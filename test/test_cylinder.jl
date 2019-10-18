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
                    point3D(1.0, 0., -5.),
                    vector3D(0., 0., 1.),
                    5.,5.
                    ))
        )
        push!(
              input,
              NamedTuple{ks}((
                    point3D(0., 0., -5.),
                    vector3D(0., 0., 1.),
                    4.,6.
                    ))
        )
        push!(
             input,
             NamedTuple{ks}((
                    point3D(0.5, 0., -5.),
                    vector3D(0.1, 1., 1.),
                    6.80798, 7.08872
                    ))
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
                     point3D(1.0, 0., 0.),
                     vector3D(0., 1., 0.)
                     ))
          )
          push!(
               input,
               NamedTuple{ks}((
                     point3D(0., 0., 0.),
                     vector3D(0., 1., 0.)
                     ))
          )
          push!(
               input,
               NamedTuple{ks}((
                     point3D(0., 0., -5.),
                     vector3D(1., 1., 1.)
                     ))
          )
          for i in input
               direction = normalize(i.direction)
               r = Ray(i.origin, direction)
               xs = local_intersect(cyl, r)
               @test length(xs) == 0
          end
    end
end
