module HomogeneousCoordinates

export point3D, vector3D, cross_product, Vec3D

using StaticArrays
import LinearAlgebra: norm, normalize, dot, cross
import Base: +, -, *, /,==, isapprox, eps, getproperty,setproperty!

mutable struct Vec3D{T}
    data::MArray{Tuple{4}, T}
    
    function Vec3D(x::T, y::T, z::T, w::T) where T <: AbstractFloat
        new{T}(MArray{Tuple{4}, T}(x, y, z, w))
    end # function

    function Vec3D(v::MArray{Tuple{4}, T}) where T <: AbstractFloat
        new{T}(v)
    end
end

@inline +(v1::Vec3D, v2::Vec3D) = Vec3D(+(v1.data, v2.data))
@inline -(v1::Vec3D, v2::Vec3D) = Vec3D(-(v1.data, v2.data))
@inline -(v::Vec3D) = Vec3D(-v.data)
@inline *(v1::Vec3D, a::T) where {T <: AbstractFloat} = Vec3D(*(v1.data, a))
@inline *(m::SMatrix, v::Vec3D) = Vec3D(m * v.data)
@inline /(v1::Vec3D, a::T) where {T <: AbstractFloat} = Vec3D(/(v1.data, a))
@inline ==(v1::Vec3D, v2::Vec3D) = v1.data == v2.data
@inline dot(v1::Vec3D, v2::Vec3D) = dot(v1.data, v2.data)
@inline norm(v1::Vec3D) = norm(v1.data)
@inline normalize(v1::Vec3D) = Vec3D(normalize(v1.data))
@inline isapprox(v1::Vec3D, v2::Vec3D; rtol=√eps()) = isapprox(
                                          v1.data,
                                          v2.data,
                                          rtol=rtol
                                          )
@inline isapprox(m::SArray, v::Vec3D; rtol=√eps()) = isapprox(
                                          m,
                                          v.data,
                                          rtol=rtol
                                          )

function getproperty(obj::Vec3D, sym::Symbol)
    symbols = (x=1,y=2,z=3,w=4)
    if sym in propertynames(symbols)
        return obj.data[symbols[sym]]
    else
        return getfield(obj, sym)
    end
end

function setproperty!(obj::Vec3D, sym::Symbol, x::T) where T<:AbstractFloat
    symbols = (x=1,y=2,z=3,w=4)
    if sym in propertynames(symbols)
        obj.data[symbols[sym]] = x
    else
        setfield!(obj, sym, x)
    end
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
    v = cross(a.data[1:3], b.data[1:3])
    return vector3D(v)
end

end
