module HomogeneousCoordinates

export point3D , vector3D ,cross_product, Vec3D

import Base: getproperty
using StaticArrays
using LinearAlgebra

struct Vec3D
    data::SVector
end

function getproperty(v::Vec3D, sym::Symbol)
    if sym === :x
        return v.data[1]
    elseif sym === :y
        return v.data[2]
    elseif sym === :z
        return v.data[3]
    elseif sym === :w
        return v.data[4]
    else
        return getfield(v, sym)
    end
end

function point3D(x::T, y::T, z::T) where T <: AbstractFloat
    return SVector{4,T}(x, y, z, one(eltype(T)))
end

function point3D(a::Array{T}) where T <: AbstractFloat
    return SVector{4,T}(a[1], a[2], a[3], one(eltype(T)))
end

function vector3D(x::T, y::T, z::T) where T <: AbstractFloat
    return SVector{4,T}(x, y, z, zero(eltype(T)))
end

function vector3D(a::Array{T}) where T <: AbstractFloat
    return SVector{4,T}(a[1], a[2], a[3], zero(eltype(T)))
end

function cross_product(a::SVector{4,T}, b::SVector{4,T}) where T <: AbstractFloat
    v = cross(a[1:3], b[1:3])
    return vector3D(v)
end

end
