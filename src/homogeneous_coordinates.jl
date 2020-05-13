module HomogeneousCoordinates

export point3D, vector3D, Vec3D, float_equal, dot, norm, normalize, cross

using StaticArrays
import LinearAlgebra: norm, normalize, dot, cross
import Base: +, -, *, /, ==
import Aether: float_equal

mutable struct Vec3D
    x::Float64
    y::Float64
    z::Float64
    w::Float64

    function Vec3D(x::Float64, y::Float64, z::Float64, w::Float64)
        new(x, y, z, w)
    end

    function Vec3D(v::Array{Float64,1})
        new(v)
    end
end

@inline +(v1::Vec3D, v2::Vec3D) =
    Vec3D(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z, v1.w + v2.w)

@inline -(v1::Vec3D, v2::Vec3D) =
    Vec3D(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z, v1.w - v2.w)

@inline -(v::Vec3D) = Vec3D(-v.x, -v.y, -v.z, -v.w)

@inline *(v::Vec3D, k::Float64) =
    Vec3D(v.x * k, v.y * k, v.z * k, v.w * k)

@inline function Base.:*(
    m::SMatrix{4,4,Float64},
    v::Vec3D)
    x = m[1, 1] * v.x + m[1, 2] * v.y + m[1, 3] * v.z + m[1, 4] * v.w
    y = m[2, 1] * v.x + m[2, 2] * v.y + m[2, 3] * v.z + m[2, 4] * v.w
    z = m[3, 1] * v.x + m[3, 2] * v.y + m[3, 3] * v.z + m[3, 4] * v.w
    w = m[4, 1] * v.x + m[4, 2] * v.y + m[4, 3] * v.z + m[4, 4] * v.w
    return Vec3D(x, y, z, w)
end

@inline /(v::Vec3D, k::Float64) =
    Vec3D(v.x / k, v.y / k, v.z / k, v.w / k)

@inline ==(v1::Vec3D, v2::Vec3D) =
    v1.x == v2.x && v1.y == v2.y && v1.z == v2.z && v1.w == v2.w

@inline dot(v1::Vec3D, v2::Vec3D) = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z

@inline norm(v::Vec3D) = √(v.x^2 + v.y^2 + v.z^2 + v.w^2)

@inline function normalize(v::Vec3D)
    n = norm(v)
    return Vec3D(v.x / n, v.y / n, v.z / n, v.w / n)
end

@inline function cross(v1::Vec3D, v2::Vec3D)
    return vector3D(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x,
    )
end

function point3D(x::Float64, y::Float64, z::Float64)
    return Vec3D(x, y, z, one(Float64))
end

function point3D(a::Array{Float64})
    return Vec3D(a[1], a[2], a[3], one(Float64))
end

function vector3D(x::Float64, y::Float64, z::Float64)
    return Vec3D(x, y, z, zero(Float64))
end

function vector3D(a::Array{Float64})
    return Vec3D(a[1], a[2], a[3], zero(Float64))
end

function float_equal(v1::Vec3D, v2::Vec3D)
    return float_equal(v1.x, v2.x) &&
           float_equal(v1.y, v2.y) &&
           float_equal(v1.z, v2.z) && float_equal(v1.w, v2.w)
end

end
