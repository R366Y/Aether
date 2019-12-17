module SceneImporters

export import_yaml_scene_file

import YAML
using Aether.CameraModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.MatrixTransformations
using Aether.WorldModule

function import_yaml_scene_file(filename::String)
    world = World()
    data = YAML.load(open(filename))
    camera = parse_camera_data(data)
    parse_lights_data(data, world)
    return camera, world
end

function parse_camera_data(yaml_data::Dict)
    camera_data = yaml_data["camera"]

    camera = Camera(camera_data["width"], camera_data["height"], Float64(camera_data["field-of-view"]))
    camera_set_transform(
        camera,
        view_transform(
            point3D(Float64.(camera_data["from"])),
            point3D(Float64.(camera_data["to"])),
            vector3D(Float64.(camera_data["up"])),
        ),
    )
    return camera
end

function parse_lights_data(yaml_data::Dict, world::World)
    lights_data = yaml_data["lights"]

    lights = LightType[]
    for light in lights_data
        color = Float64.(light["intensity"])
        at = Float64.(light["at"])
        l = PointLight(point3D(at), ColorRGB(color[1], color[2], color[3]))
        push!(lights, l)
    end
    add_lights!(world, lights...)
end

function parse_materials_data(yaml_data::Dict)
    materials_data = yaml_data["materials"]
    
    materials = Dict()
    for material_yaml in materials_data
        material_name = material_yaml["define"]
        material = default_material()
        push!(materials, material_name=>material)
    end
end

function parse_transforms_data(yaml_data::Dict)

end

function parse_objects_data(yaml_data::Dict)

end

end