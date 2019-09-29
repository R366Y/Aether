module Patterns

export Pattern, StripePattern, TestPattern, GradientPattern, RingPattern,
       CheckerPattern, stripe_pattern, pattern_at, pattern_at_shape,
       set_pattern_transform

import Aether.BaseGeometricType: GeometricObject
import Aether.ColorsModule: ColorRGB, black, white
import Aether.HomogeneousCoordinates: Vec3D
import Aether.MatrixTransformations: Matrix4x4, identity_matrix

abstract type Pattern end

function set_pattern_transform(pattern::Pattern, matrix::Matrix4x4)
    pattern.transform = matrix
    pattern.inverse = inv(matrix)
end

function pattern_at_shape(pattern::Pattern, object::GeometricObject,
    world_point::Vec3D )
    object_point = object.inverse * world_point
    pattern_point = pattern.inverse * object_point

    return pattern_at(pattern, pattern_point)
end


mutable struct StripePattern <: Pattern
    a::ColorRGB
    b::ColorRGB
    transform::Matrix4x4
    inverse::Matrix4x4

    function StripePattern(a::ColorRGB, b::ColorRGB)
        new(a, b, identity_matrix(Float64), identity_matrix(Float64))
    end
end

function stripe_pattern(c1::ColorRGB, c2::ColorRGB)
    return StripePattern(c1, c2)
end

function pattern_at(pattern::StripePattern, point::Vec3D)
    if mod(floor(point.x), 2) == 0
        return pattern.a
    end
    return pattern.b
end

mutable struct GradientPattern <: Pattern
    a::ColorRGB
    b::ColorRGB
    transform::Matrix4x4
    inverse::Matrix4x4

    function GradientPattern(a::ColorRGB, b::ColorRGB)
        new(a, b, identity_matrix(Float64), identity_matrix(Float64))
    end
end

function pattern_at(gradient::GradientPattern, point::Vec3D)
    distance = gradient.b - gradient.a
    fraction = point.x - floor(point.x)
    return gradient.a + distance * fraction
end

mutable struct RingPattern <: Pattern
    a::ColorRGB
    b::ColorRGB
    transform::Matrix4x4
    inverse::Matrix4x4

    function RingPattern(a::ColorRGB, b::ColorRGB)
        new(a, b, identity_matrix(Float64), identity_matrix(Float64))
    end
end

function pattern_at(ring::RingPattern, point::Vec3D)
    if mod(floor(√(point.x^2 + point.z^2)), 2) == 0
        return ring.a
    end
    return ring.b
end

mutable struct CheckerPattern <: Pattern
    a::ColorRGB
    b::ColorRGB
    transform::Matrix4x4
    inverse::Matrix4x4

    function CheckerPattern(a::ColorRGB, b::ColorRGB)
        new(a, b, identity_matrix(Float64), identity_matrix(Float64))
    end
end

function pattern_at(checker::CheckerPattern, point::Vec3D)
    if mod(floor(point.x) + floor(point.y) + floor(point.z), 2) == 0
        return checker.a
    end
    return checker.b
end

mutable struct TestPattern <: Pattern
    a::Union{Nothing,ColorRGB}
    b::Union{Nothing,ColorRGB}
    transform::Matrix4x4
    inverse::Matrix4x4

    function TestPattern()
        new(nothing, nothing, identity_matrix(Float64), identity_matrix(Float64))
    end
end

function pattern_at(pattern::TestPattern, point::Vec3D)
    return ColorRGB(point.x, point.y, point.z)
end

end
