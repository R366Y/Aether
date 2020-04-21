module Materials

export Material, default_material, compare_materials, gobject_material!, gobject_material
export color, color!, ambient, ambient!, diffuse, diffuse!, specular, specular!
export shininess, shininess!, reflective, reflective!, transparency, transparency!
export refractive_index, refractive_index!

import Aether.BaseGeometricType: GeometricObject
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
    transparency::Float64
    refractive_index::Float64
    pattern::Union{Nothing,Pattern}

    function Material(
        color::ColorRGB,
        ambient::Float64,
        diffuse::Float64,
        specular::Float64,
        shininess::Float64,
        reflective::Float64,
        transparency::Float64,
        refractive_index::Float64,
    )
        new(
            color,
            ambient,
            diffuse,
            specular,
            shininess,
            reflective,
            transparency,
            refractive_index,
            nothing,
        )
    end
end


function default_material()
    return Material(
        ColorRGB(1.0, 1.0, 1.0),
        0.1,
        0.9,
        0.9,
        200.0,
        0.0,
        0.0,
        1.0,
        )
end
    
color(material::Material) = material.color
color!(material::Material, color::ColorRGB) = material.color = color
ambient(material::Material) = material.ambient
ambient!(material::Material, ambient::Float64) = material.ambient = ambient
diffuse(material::Material) = material.diffuse
diffuse!(material::Material, diffuse::Float64) = material.diffuse = diffuse
specular(material::Material) = material.specular
specular!(material::Material, specular::Float64) = material.specular = specular
shininess(material::Material) = material.shininess
shininess!(material::Material, shininess::Float64) = material.shininess = shininess
reflective(material::Material) = material.reflective
reflective!(material::Material, reflective::Float64) = material.reflective = reflective
transparency(material::Material) = material.transparency
transparency!(material::Material, transparency::Float64) = material.transparency = transparency
refractive_index(material::Material) = material.refractive_index
refractive_index!(material::Material, refractive_index) = material.refractive_index = refractive_index

@inline ==(m1::Material, m2::Material) = compare_materials(m1, m2)


function gobject_material!(gobject::T, material::Material) where {T<:GeometricObject}
    gobject.material = material
end

function gobject_material(gobject::T)::Material where {T<:GeometricObject}
    return gobject.material
end
    
function compare_materials(m1::Material, m2::Material)
    return m1.color == m2.color &&
           m1.ambient == m2.ambient &&
           m1.diffuse == m2.diffuse &&
           m1.specular == m2.specular && m1.shininess == m2.shininess
end

end
