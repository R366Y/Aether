using StaticArrays

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
