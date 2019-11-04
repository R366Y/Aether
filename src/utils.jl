module Utils

export push_tuple

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
