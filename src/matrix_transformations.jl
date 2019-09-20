module MatrixTransformations

using Aether.HomogeneousCoordinates
using LinearAlgebra
using StaticArrays

export identity_matrix, translation, scaling,
       rotation_x, rotation_y, rotation_z,
       shearing, view_transform

function identity_matrix(T::Type)
    return SMatrix{4,4,T}(I)
end

function translation(x::Float64, y::Float64, z::Float64)
    return SMatrix{4,4,Float64}([
        1. 0. 0. x;
        0. 1. 0. y;
        0. 0. 1. z;
        0. 0. 0. 1.
    ])
end

function scaling(x::Float64, y::Float64, z::Float64)
    return SMatrix{4,4,Float64}([
        x 0. 0. 0.;
        0. y 0. 0.;
        0. 0. z 0.;
        0. 0. 0. 1.
    ])
end

function rotation_x(θ::Float64)
    s, c = sincos(θ)
    return SMatrix{4,4,Float64}([
        1. 0. 0. 0.;
        0. c -s 0.;
        0. s c 0.;
        0. 0. 0. 1.
    ])
end

function rotation_y(θ::Float64)
    s, c = sincos(θ)
    return SMatrix{4,4,Float64}([
        c 0. s 0.;
        0. 1. 0. 0.;
        -s 0. c 0.;
        0. 0. 0. 1.
    ])
end

function rotation_z(θ::Float64)
    s, c = sincos(θ)
    return SMatrix{4,4,Float64}([
        c -s 0. 0.;
        s c 0. 0.;
        0. 0. 1. 0.;
        0. 0. 0. 1.
    ])
end

function shearing(x_y::Float64, x_z::Float64, y_x::Float64,
                  y_z::Float64, z_x::Float64, z_y::Float64)
    return SMatrix{4,4,Float64}([
        1. x_y x_z 0.;
        y_x 1. y_z 0.;
        z_x z_y 1. 0.;
        0. 0. 0. 1.
    ])
end

function view_transform(from::Vec3D, to::Vec3D, up::Vec3D)
    forward = normalize(to - from)
    upn = normalize(up)
    left = cross(forward, upn)
    true_up = cross(left, forward)
    orientation = SMatrix{4,4,Float64}([left.x left.y left.z 0.;
                                       true_up.x true_up.y true_up.z 0.;
                                       -forward.x -forward.y -forward.z 0.;
                                        0. 0. 0. 1.])
    return orientation * translation(-from.x, -from.y, -from.z)
end

end
