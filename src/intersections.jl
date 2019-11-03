import Aether.BaseGeometricType: GeometricObject

struct Intersection{O<:GeometricObject}
    t::Float64
    gobject::O

    function Intersection(t::Float64, gobject::O) where O <: GeometricObject
        new{O}(t, gobject)
    end
end

function hit(is::Array)
    result::Union{Intersection, Nothing} = nothing
    min = Inf
    index = -1
    for (idx,val) in enumerate(is)
        if val.t >= 0. && val.t < min
            min = val.t
            index = idx
        end
    end
    if min < Inf
        result = is[index]
    end
    return result
end
