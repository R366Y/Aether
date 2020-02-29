module SceneImporters

include("yaml_utils.jl")

export import_yaml_scene_file

import YAML
using Aether
using Aether.BaseGeometricType
using Aether.CameraModule
using Aether.ColorsModule
using Aether.HomogeneousCoordinates
using Aether.Lights
using Aether.Materials
using Aether.MatrixTransformations
using Aether.Shapes
using Aether.WorldModule

function import_yaml_scene_file(filename::String)
    data = YAML.load(open(filename))
    camera = parse_camera_data(data)
    lights = parse_lights_data(data)
    materials = parse_materials_data(data)
    transforms = parse_transforms_data(data)
    gobjects = parse_objects_data(data, materials, transforms)
    return camera, lights, gobjects
end

function parse_camera_data(yaml_data::Dict)
    camera_data = yaml_camera_data(yaml_data)

    camera = Camera(yaml_camera_width(camera_data),
                    yaml_camera_height(camera_data),
                    yaml_camera_fov(camera_data))
    camera_set_transform(
        camera,
        view_transform(
            point3D(yaml_camera_from(camera_data)),
            point3D(yaml_camera_to(camera_data)),
            vector3D(yaml_camera_up(camera_data)),
        ),
    )
    return camera
end

function parse_lights_data(yaml_data::Dict)
    lights_data = yaml_lights_data(yaml_data)

    lights = LightType[]
    for light in lights_data
        color = yaml_lights_intensity(light)
        at = yaml_lights_at(light)
        l = PointLight(point3D(at), ColorRGB(color...))
        push!(lights, l)
    end
    return lights
end

function parse_materials_data(yaml_data::Dict)
    materials = Dict()
    if !has_predefined_materials(yaml_data)
        return materials
    end
    materials_data = yaml_materials_data(yaml_data)
    for material_yaml in materials_data
        material_name = yaml_define(material_yaml)
        material = default_material()
        __extend_material(material, material_yaml, materials)
        # fill materials fields
        for mat_prop in collect(keys(material_yaml))
            (mat_prop == "extend" || mat_prop == "define") && continue
            value = material_yaml[mat_prop]
            __set_material_property(material, mat_prop, value)
        end
        push!(materials, material_name=>material)
    end
    return materials
end

function parse_transforms_data(yaml_data::Dict)
    transforms = Dict()
    if !has_transforms(yaml_data)
        return transforms
    end
    transforms_data = yaml_transforms_data(yaml_data)
    for transform_yaml in transforms_data
        transform_name = yaml_define(transform_yaml)
        # transformation order declared in the yaml file
        # must be reverted when executed thus following the law of matrix multiplication
        # i.e. the last transformation must come first in the order of matrix multiplications
        # see __add_transform
        matrices = []
        # check if the transformation extends another transformation
        if has_extend(transform_yaml)
            extended = yaml_extend(transform_yaml)
            matrices = deepcopy(transforms[extended])
        end
        for matr_trans in yaml_value(transform_yaml)
            __add_transform(matr_trans, matrices)
        end
        push!(transforms, transform_name=>matrices)
    end
    return transforms
end

function parse_objects_data(yaml_data::Dict, materials::Dict, transforms::Dict)
    gobjects_data = yaml_gobject_data(yaml_data)
    gobjects = GeometricObject[]
    predefined_objects = Dict()

    for gobject_yaml in gobjects_data
        if has_define(gobject_yaml)
            gobject_name = yaml_define(gobject_yaml)
            gobject = __parse_gobject_yaml(yaml_value(gobject_yaml), materials, transforms, predefined_objects)
            push!(predefined_objects, gobject_name => gobject)
        else
            gobject = __parse_gobject_yaml(gobject_yaml, materials, transforms, predefined_objects)
            push!(gobjects, gobject)
        end
    end
    return gobjects
end

function __parse_gobject_yaml(gobject_yaml, materials, transforms, predefined_obj = nothing)
    gobject_type = gobject_yaml["add"]
    gobject = TestShape()
    if gobject_type == "cone"
        gobject = Cone()
        if haskey(gobject_yaml, "min")
            gobject.minimum = gobject_yaml["min"]
        end
        if haskey(gobject_yaml, "max")
            gobject.maximum = gobject_yaml["max"]
        end
        if haskey(gobject_yaml, "closed")
            gobject.closed = gobject_yaml["closed"]
        end
    elseif gobject_type == "cube"
        gobject = Cube()
    elseif gobject_type == "cylinder"
        gobject = Cylinder()
        if haskey(gobject_yaml, "min")
            gobject.minimum = gobject_yaml["min"]
        end
        if haskey(gobject_yaml, "max")
            gobject.maximum = gobject_yaml["max"]
        end
        if haskey(gobject_yaml, "closed")
            gobject.closed = gobject_yaml["closed"]
        end
    elseif gobject_type == "plane"
        gobject = Plane()
    elseif gobject_type == "sphere"
        gobject = default_sphere()
    elseif gobject_type == "group"
        shapes = GeometricObject[]
        for child_gobject in gobject_yaml["children"]
            child = __parse_gobject_yaml(child_gobject, materials, transforms, predefined_obj)
            push!(shapes, child)
        end
        gobject = group_of(shapes)
    elseif gobject_type == "obj"
        file_path = gobject_yaml["file"]
        parser = parse_obj_file(file_path)
        gobject = obj_to_group(parser)
    else
        # it must be a predefined object then
        if isnothing(predefined_obj)
            throw(ArgumentError("You must pass a list of predefined objects if $gobject_type is not one of the standard objects!"))
        end
        if !haskey(predefined_obj, gobject_type)
            throw(ArgumentError("$gobject_type is not one of the standard objects and it has not been defined!"))
        end
        gobject = deepcopy(predefined_obj[gobject_type])
    end

    if haskey(gobject_yaml, "shadow")
        gobject.shadow = gobject_yaml["shadow"]
    end

    __parse_gobject_material!(gobject, gobject_yaml, materials)
    __parse_gobject__transform!(gobject, gobject_yaml, transforms)

    return gobject
end

function __parse_gobject_material!(gobject::GeometricObject, gobject_yaml::Dict, materials::Dict)
    if haskey(gobject_yaml, "material")
        material_yaml = gobject_yaml["material"]
        material = default_material()
        # check if the material extends another material
        if haskey(material_yaml,"extend")
            extended = material_yaml["extend"]
            material = deepcopy(materials[extended])
        end
        for mat_prop in collect(keys(material_yaml))
            mat_prop == "extend" && continue
            value = material_yaml[mat_prop]
            __set_material_property(material, mat_prop, value)
        end

        if typeof(gobject) == Group
            apply_material(gobject, material)
        else
            gobject.material = material
        end
    end
end

function __parse_gobject__transform!(gobject::GeometricObject, gobject_yaml::Dict, transforms::Dict)
    if haskey(gobject_yaml, "transform")
        transformation_yaml = gobject_yaml["transform"]
        matrices = []
        for matr_trans in transformation_yaml
            # check if the transformation extends another transformation
            if typeof(matr_trans) == String
                matrices = deepcopy(transforms[matr_trans])
                continue
            end
            __add_transform(matr_trans, matrices)
        end
        matrices = [m[2] for m in matrices]
        if !isempty(matrices)
            transform = identity_matrix(Float64)
            for matrix in matrices
                transform = transform * matrix
            end
            transform = transform * gobject.transform
            set_transform(gobject, transform)
        end
    end
end

function __extend_material(material::Material, yaml_data::Dict, materials::Dict)
    # check if the material extends another material
    if has_extend(yaml_data)
        material_name = yaml_extend(yaml_data)
        material = deepcopy(materials[material_name])
    end
end

function __set_material_property(material, material_property, value)
    if material_property == "refractive-index"
        material_property = "refractive_index"
    end
    if material_property == "color"
        value = __array_to_ColorRGB(value)
    else
        value = Float64(value)
    end
    property = Symbol(material_property)
    setfield!(material, property, value)
end

function __add_transform(yaml_matrix_transformations, matrices)
    MATRIX_OP_NAME_INDEX = 1
    MATRIX_OP_PARAMETERS_START_INDEX = 2
    matrix_operation = yaml_matrix_transformations[MATRIX_OP_NAME_INDEX]
    value = yaml_matrix_transformations[MATRIX_OP_PARAMETERS_START_INDEX:end]
    # add the transformation in the first position of the array
    # because the order of the matrix multiplication is inverted
    if matrix_operation == "translate"
        value = Float64.(value)
        pushfirst!(matrices, ["translate", translation(value[1], value[2], value[3])])
    elseif matrix_operation == "scale"
        value = Float64.(value)
        pushfirst!(matrices, ["scale", scaling(value[1], value[2], value[3])])
    elseif matrix_operation == "rotate-x"
        value = Float64(value[1])
        pushfirst!(matrices, ["rotate-x", rotation_x(value)])
    elseif matrix_operation == "rotate-y"
        value = Float64(value[1])
        pushfirst!(matrices, ["rotate-y", rotation_y(value)])
    elseif matrix_operation == "rotate-z"
        value = Float64(value[1])
        pushfirst!(matrices, ["rotate-z", rotation_z(value)])
    end
end

function __array_to_ColorRGB(array)
    array = Float64.(array)
    return ColorRGB(array[1], array[2], array[3])
end

end
