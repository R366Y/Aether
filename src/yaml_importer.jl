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
    materials = parse_materials_data(data)
    transforms = parse_transforms_data(data)
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
        # check if the material extends another material
        if haskey(material_yaml,"extend")
            extended = material_yaml["extend"]
            material = deepcopy(materials[extended])
        end
        # fill materials fields
        for mat_prop in collect(keys(material_yaml))
            (mat_prop == "extend" || mat_prop == "define") && continue
            prop = Symbol(mat_prop)
            value = material_yaml[mat_prop]
            if mat_prop == "color"
                value = __array_to_ColorRGB(value)
            else
                value = Float64(value)
            end
            setfield!(material, prop, value)
        end
        push!(materials, material_name=>material)
    end
    return materials
end

function parse_transforms_data(yaml_data::Dict)
    transforms_data = yaml_data["transforms"]

    transforms = Dict()
    for transform_yaml in transforms_data
        transform_name = transform_yaml["define"]
        # transformation order declared in the yaml file 
        # must be reverted when executed thus following the law of matrix multiplication
        # i.e. the last transformation must come first in the order of matrix multiplications
        matrices = []
        # check if the transformation extends another transformation
        if haskey(transform_yaml,"extend")
            extended = transform_yaml["extend"]
            matrices = deepcopy(transforms[extended])
        end
        for matr_trans in transform_yaml["value"]
            matr_op = matr_trans[1]
            value = matr_trans[2:end]
            if matr_op == "translate"
                value = Float64.(value)
                # remove entry if already exists in case 
                # the transformation extends an existing one
                filter!(x-> x[1] != "translate", matrices)
                pushfirst!(matrices, ["translate", translation(value[1], value[2], value[3])])
            elseif matr_op == "scale"
                value = Float64.(value)
                filter!(x-> x[1] != "scale", matrices)
                pushfirst!(matrices, ["scale", scaling(value[1], value[2], value[3])])
            elseif matr_op == "rotate-x"
                value = Float64(value[1])
                filter!(x-> x[1] != "rotate-x", matrices)
                pushfirst!(matrices, ["rotate-x", rotation_x(value)])
            elseif matr_op == "rotate-y"
                value = Float64(value[1])
                filter!(x-> x[1] != "rotate-y", matrices)
                pushfirst!(matrices, ["rotate-y", rotation_y(value)])
            elseif matr_op == "rotate-z"
                value = Float64(value[1])
                filter!(x-> x[1] != "rotate-z", matrices)
                pushfirst!(matrices, ["rotate-z", rotation_z(value)])
            end
        end
        push!(transforms, transform_name=>matrices)
    end
    return transforms
end

function parse_objects_data(yaml_data::Dict)

end

function __array_to_ColorRGB(array)
    array = Float64.(array)
    return ColorRGB(array[1], array[2], array[3])
end

end