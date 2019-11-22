module ProjectileTest
using StaticArrays
using LinearAlgebra
using Plots

using Aether.HomogeneousCoordinates

struct Projectile
    position::Vec3D
    velocity::Vec3D
end

struct Environment
    gravity::Vec3D
    wind::Vec3D
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
    while p.position.y > 0
        p = tick(e, p)
        println("x value $(p.position.x) y value $(p.position.y)")
        number_of_ticks+=1
        position_array = vcat([p.position.x, p.position.y]' ,position_array)
    end
    print("Total ticks: $number_of_ticks")
    return position_array
end

positions = run_simulation()
display(plot(positions[:,1], positions[:,2], c="red", line=:dash))
end
