using StaticArrays

export translation, scaling,
       rotation_x, rotation_y, rotation_z,
       shearing

function translation(x::T, y::T, z::T) where T <: AbstractFloat
    return @SMatrix T[
        1 0 0 x;
        0 1 0 y;
        0 0 1 z;
        0 0 0 1
    ]
end

function scaling(x::T, y::T, z::T) where T <: AbstractFloat
    return @SMatrix T[
        x 0 0 0;
        0 y 0 0;
        0 0 z 0;
        0 0 0 1
    ]
end

function rotation_x(θ::T) where T <: AbstractFloat
    s, c = sincos(θ)
    return @SMatrix T[
        1 0 0 0;
        0 c -s 0;
        0 s c 0;
        0 0 0 1
    ]
end

function rotation_y(θ::T) where T <: AbstractFloat
    s, c = sincos(θ)
    return @SMatrix T[
        c 0 s 0;
        0 1 0 0;
        -s 0 c 0;
        0 0 0 1
    ]
end

function rotation_z(θ::T) where T <: AbstractFloat
    s, c = sincos(θ)
    return @SMatrix T[
        c -s 0 0;
        s c 0 0;
        0 0 1 0;
        0 0 0 1
    ]
end

function shearing(x_x::T, x_z::T, y_x::T, y_z::T, z_x::T, z_y::T) where T <: AbstractFloat
    return @SMatrix T[
        1 x_y x_z 0;
        y_x 1 y_z 0;
        z_x z_y 1 0;
        0   0  0  1
    ]
end
