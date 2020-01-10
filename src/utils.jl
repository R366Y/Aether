module Utils

using Base.Iterators

export Generator, next!, push_tuple

mutable struct Generator 
    sequence
    next::Int
    function Generator(x...)
        t = push_tuple(x)
        new(cycle(x),1)
    end 
end

function next!(g::Generator)
    n = iterate(g.sequence, g.next)
    element, state = n
    g.next = state
    return element
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
