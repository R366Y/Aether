module HomogeneousCoordinates

export point3D, vector3D, cross_product, Vec3D

using StaticArrays
using LinearAlgebra

struct Vec3D{T} <: FieldVector{4,T}
    x::T
    y::T
    z::T
    w::T
    function Vec3D(x::T, y::T, z::T, w::T) where T <: AbstractFloat
        new{T}(x, y, z, w)
    end # function
end

function point3D(x::T, y::T, z::T) where T <: AbstractFloat
    return Vec3D(x, y, z, one(eltype(T)))
end

function point3D(a::Array{T}) where T <: AbstractFloat
    return Vec3D(a[1], a[2], a[3], one(eltype(T)))
end

function vector3D(x::T, y::T, z::T) where T <: AbstractFloat
    return Vec3D(x, y, z, zero(eltype(T)))
end

function vector3D(a::Array{T}) where T <: AbstractFloat
    return Vec3D(a[1], a[2], a[3], zero(eltype(T)))
end

function cross_product(a::Vec3D, b::Vec3D)
    v = cross(a[1:3], b[1:3])
    return vector3D(v)
end

end
