module Shaders

export lighting

using Aether.ColorsModule
using Aether.Materials
using Aether.Lights
using Aether.HomogeneousCoordinates
using Aether.Rays

using LinearAlgebra

function lighting(
    material::Material,
    light::PointLight,
    point::Vec3D,
    eyev::Vec3D,
    normalv::Vec3D
)
# combine the surface color with the light's color/intensity
effective_color = material.color * light.intensity
# find the direction to the light source
lightv = normalize(light.position - point)
# compute the ambient contribution
ambient = effective_color * material.ambient

# light_dot_normal represents the cosine of the angle between the
# light vector and the normal vector. A negative number means the
# light is on the other side of the surface.
light_dot_normal = dot(lightv, normalv)
diffuse = ColorRGB()
specular = ColorRGB()
if light_dot_normal >= 0.
    diffuse = effective_color * material.diffuse * light_dot_normal

    # reflect_dot_eye represents the cosine of the angle between the
    # reflection vector and the eye vector. A negative number means the
    # light reflects away from the eye.
    reflectv = reflect(-lightv, normalv)
    reflect_dot_eye = dot(reflectv, eyev)
    if reflect_dot_eye > 0.
        # compute the specular contribution
        factor = reflect_dot_eye ^ material.shininess
        specular = light.intensity * material.specular * factor
    end
end
return ambient + diffuse + specular
end

end  # module Shaders
