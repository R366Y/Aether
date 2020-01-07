using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Test

@testset "Lights" begin
    @testset "A point light has position and intensity" begin
        intensity = ColorRGB(1.,1.,1.)
        position = point3D(0.,0.,0.)
        light = PointLight(position, intensity)
        @test light.position == position
        @test light.intensity == intensity
    end

    @testset "Creating an area light" begin
        corner = point3D(0., 0., 0.)
        v1 = vector3D(2., 0., 0.)
        v2 = vector3D(0., 0., 1.)
        light = AreaLight(corner, v1, 4, v2, 2, white)
        @test light.corner == corner
        @test light.uvec == vector3D(0.5, 0., 0.)
        @test light.usteps == 4
        @test light.vvec == vector3D(0., 0., 0.5)
        @test light.vsteps == 2
        @test light.samples == 8
        @test light.position == point3D(1., 0., 0.5)
    end

    @testset "Finding a single point on an area light" begin
        corner = point3D(0., 0., 0.)
        v1 = vector3D(2., 0., 0.)
        v2 = vector3D(0., 0., 1.)
        light = AreaLight(corner, v1, 4, v2, 2, white)

        input = NamedTuple[]
        ks = (:u, :v, :result)
        push!(input, NamedTuple{ks}((0, 0, point3D(0.25, 0., 0.25))))
        push!(input, NamedTuple{ks}((1, 0, point3D(0.75, 0., 0.25))))
        push!(input, NamedTuple{ks}((0, 1, point3D(0.25, 0., 0.75))))
        push!(input, NamedTuple{ks}((2, 0, point3D(1.25, 0., 0.25))))
        push!(input, NamedTuple{ks}((3, 1, point3D(1.75, 0., 0.75))))

        for i in input
            @test point_on_light(light, i.u, i.v) == i.result
        end
    end
end 
