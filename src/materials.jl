module Materials

export Material, default_material, compare_materials

using Aether.ColorsModule

mutable struct Material{T<:AbstractFloat}
    color::ColorRGB
    ambient::T
    diffuse::T
    specular::T
    shininess::T
end

function default_material()
    return Material(ColorRGB(1., 1., 1.), 0.1, 0.9, 0.9, 200.)
end

function compare_materials(m1::Material, m2::Material)
    return m1.color == m2.color &&
           m1.ambient == m2.ambient &&
           m1.diffuse == m2.diffuse &&
           m1.specular == m2.specular && m1.shininess == m2.shininess
end

end  # module Materials
