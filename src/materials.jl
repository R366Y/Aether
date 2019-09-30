module Materials

export Material, default_material, compare_materials

import Aether.ColorsModule: ColorRGB
import Aether.Patterns: Pattern
import Base: ==

mutable struct Material
    color::ColorRGB
    ambient::Float64
    diffuse::Float64
    specular::Float64
    shininess::Float64
    reflective::Float64
    pattern::Union{Nothing,Pattern}

    function Material(color::ColorRGB, ambient::Float64, diffuse::Float64,
                      specular::Float64, shininess::Float64, reflective::Float64)
        new(color, ambient, diffuse, specular, shininess, reflective, nothing)
    end
end

@inline ==(m1::Material, m2::Material) = compare_materials(m1, m2)

function default_material()
    return Material(ColorRGB(1., 1., 1.), 0.1, 0.9, 0.9, 200., 0.)
end

function compare_materials(m1::Material, m2::Material)
    return m1.color == m2.color &&
           m1.ambient == m2.ambient &&
           m1.diffuse == m2.diffuse &&
           m1.specular == m2.specular && m1.shininess == m2.shininess
end

end  # module Materials
