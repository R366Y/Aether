module ProjectileTest
using StaticArrays
using LinearAlgebra
using Plots

using Aether.HomogeneousCoordinates

struct Projectile{T<:AbstractArray}
    position::T
    velocity::T
end

struct Environment{T<:AbstractArray}
    gravity::T
    wind::T
end


function tick(env::Environment, proj::Projectile)
    position = proj.position + proj.velocity
    velocity = proj.velocity + env.gravity + env.wind
    return Projectile(position, velocity)
end

function run_simulation()
    p = Projectile(point3D(0.0, 1.0, 0.0), normalize(vector3D(1.0, 1.0, 0.0)))
    e = Environment(vector3D(0.0, -0.1, 0.0), vector3D(-0.01, 0.0, 0.0))
    number_of_ticks = 0
    position_array = Matrix{Float64}(undef,0,2)
    while p.position[2] > 0
        p = tick(e, p)
        println("x value $(p.position[1]) y value $(p.position[2])")
        number_of_ticks+=1
        position_array = vcat([p.position[1], p.position[2]]' ,position_array)
    end
    print("Total ticks: $number_of_ticks")
    return position_array
end

positions = run_simulation()
display(plot(positions[:,1], positions[:,2], c="red", line=:dash))
end
