module Utils

using Base.Iterators
using Random

export Generator, RandomGenerator, next!, push_tuple

mutable struct Generator 
    sequence
    next::Int
    function Generator(x...)
        t = push_tuple(x)
        new(cycle(x),1)
    end 
end

mutable struct RandomGenerator
    rng

    function RandomGenerator()
        new(MersenneTwister(1234))
    end

    function RandomGenerator(seed::Int)
        new(MersenneTwister(seed))
    end
end

function next!(g::Generator)
    n = iterate(g.sequence, g.next)
    element, state = n
    g.next = state
    return element
end

function next!(rg::RandomGenerator)
    return rand(Float64, 1)[1]
end

@generated function push_tuple(x...)
    ret = Expr(:tuple)
    for i = 1:length(x)
        if !(x[i] <: Nothing)
            push!(ret.args, :(x[$i]))
        end
    end
    return ret
end

end
