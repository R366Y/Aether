module HomogeneousCoordinates
export point3D
export vector3D
export cross_product

using StaticArrays
using LinearAlgebra

function point3D(x::T, y::T, z::T) where T <: AbstractFloat
    return SVector{4,T}(x, y, z, 1.0)
end

function point3D(a::Array{T}) where T <: AbstractFloat
    return SVector{4,T}(a[1], a[2], a[3], 1.0)
end

function vector3D(x::T, y::T, z::T) where T <: AbstractFloat
    return SVector{4,T}(x, y, z, 0.0)
end

function vector3D(a::Array{T}) where T <: AbstractFloat
    return SVector{4,T}(a[1], a[2], a[3], 0.0)
end

function cross_product(a::SVector{4,T}, b::SVector{4,T}) where T <: AbstractFloat
    v = cross(a[1:3], b[1:3])
    return vector3D(v)
end

end
