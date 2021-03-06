module Shaders

export lighting

using Aether.ColorsModule
using Aether.Materials
using Aether.Lights
using Aether.HomogeneousCoordinates
using Aether.Rays
import Aether.Patterns: pattern_at_shape
import Aether.BaseGeometricType: GeometricObject

using LinearAlgebra

function lighting(
    material::Material,
    object::GeometricObject,
    light::PointLight,
    point::Vec3D,
    eyev::Vec3D,
    normalv::Vec3D,
    light_intensity::Float64
)
    color = material.color
    if material.pattern != nothing
        color = pattern_at_shape(material.pattern, object, point)
    end
    # combine the surface color with the light's color/intensity
    effective_color = color * light.intensity
    # compute the ambient contribution
    ambient = effective_color * material.ambient
    
    # find the direction to the light source
    lightv = normalize(light.position - point)
    # light_dot_normal represents the cosine of the angle between the
    # light vector and the normal vector. A negative number means the
    # light is on the other side of the surface.
    light_dot_normal = dot(lightv, normalv)
    diffuse = ColorRGB()
    specular = ColorRGB()
    if light_dot_normal >= 0.0 && light_intensity > 0.0
        diffuse = effective_color * material.diffuse * light_dot_normal

        # reflect_dot_eye represents the cosine of the angle between the
        # reflection vector and the eye vector. A negative number means the
        # light reflects away from the eye.
        reflectv = reflect(-lightv, normalv)
        reflect_dot_eye = dot(reflectv, eyev)
        if reflect_dot_eye > 0.0
            # compute the specular contribution
            factor = reflect_dot_eye^material.shininess
            specular = light.intensity * material.specular * factor
        end
    end
    return ambient + light_intensity * (diffuse + specular)
end

function lighting(    
    material::Material,
    object::GeometricObject,
    light::AreaLight,
    point::Vec3D,
    eyev::Vec3D,
    normalv::Vec3D,
    light_intensity::Float64
)
    color = material.color
    if material.pattern != nothing
        color = pattern_at_shape(material.pattern, object, point)
    end
    # combine the surface color with the light's color/intensity
    effective_color = color * light.intensity
    # compute the ambient contribution
    ambient = effective_color * material.ambient

    sum = black
    for v in 0:light.vsteps - 1
        for u in 0:light.usteps - 1
            light_position = point_on_light(light, u, v)
            # find the direction to the light source
            lightv = normalize(light.position - point)
            # light_dot_normal represents the cosine of the angle between the
            # light vector and the normal vector. A negative number means the
            # light is on the other side of the surface.
            light_dot_normal = dot(lightv, normalv)
            
            if light_dot_normal < 0.0 || light_intensity == 0.0
                continue
            end
            sum = sum + effective_color * material.diffuse * light_dot_normal

            # reflect_dot_eye represents the cosine of the angle between the
            # reflection vector and the eye vector. A negative number means the
            # light reflects away from the eye.
            reflectv = reflect(-lightv, normalv)
            reflect_dot_eye = dot(reflectv, eyev)
            if reflect_dot_eye > 0.0
                # compute the specular contribution
                factor = reflect_dot_eye^material.shininess
                sum = sum + light.intensity * material.specular * factor
            end
        end
    end
    return ambient + (sum / Float64(light.samples)) * light_intensity
end

end