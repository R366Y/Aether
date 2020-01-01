module SceneImporters

export import_yaml_scene_file

import YAML
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
    world = World()
    data = YAML.load(open(filename))
    camera = parse_camera_data(data)
    parse_lights_data(data, world)
    materials = parse_materials_data(data)
    transforms = parse_transforms_data(data)
    parse_objects_data(data, materials, transforms, world)
    # TODO: return list of gobjects and lights instead of world
    # because gobjects can be grouped later and divide the scene with AABB
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
    materials = Dict()
    if !haskey(yaml_data, "materials")
        return materials
    end
    materials_data = yaml_data["materials"]
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
            value = material_yaml[mat_prop]
            __set_material_property(material, mat_prop, value)
        end
        push!(materials, material_name=>material)
    end
    return materials
end

function parse_transforms_data(yaml_data::Dict)
    transforms = Dict()
    if !haskey(yaml_data, "transforms")
        return transforms
    end
    transforms_data = yaml_data["transforms"]
    for transform_yaml in transforms_data
        transform_name = transform_yaml["define"]
        # transformation order declared in the yaml file
        # must be reverted when executed thus following the law of matrix multiplication
        # i.e. the last transformation must come first in the order of matrix multiplications
        # see __add_transform
        matrices = []
        # check if the transformation extends another transformation
        if haskey(transform_yaml,"extend")
            extended = transform_yaml["extend"]
            matrices = deepcopy(transforms[extended])
        end
        for matr_trans in transform_yaml["value"]
            matr_op = matr_trans[1]
            value = matr_trans[2:end]
            __add_transform(matr_op, value, matrices)
        end
        push!(transforms, transform_name=>matrices)
    end
    return transforms
end

function parse_objects_data(yaml_data::Dict, materials, transforms, world)
    gobjects_data = yaml_data["gobjects"]

    for gobject_yaml in gobjects_data
        gobject_type = gobject_yaml["add"]
        gobject = TestShape()
        if gobject_type == "cone"
            gobject = Cone()
        elseif gobject_type == "cube"
            gobject = Cube()
        elseif gobject_type == "cylinder"
            gobject = Cylinder()
        elseif gobject_type == "plane"
            gobject = Plane()
        elseif gobject_type == "sphere"
            gobject = default_sphere()
        end

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
            gobject.material = material
        end

        if haskey(gobject_yaml, "transform")
            transformation_yaml = gobject_yaml["transform"]
            matrices = []
            for matr_trans in transformation_yaml
                # check if the transformation extends another transformation
                if typeof(matr_trans) == String
                    matrices = deepcopy(transforms[matr_trans])
                    continue
                end
                matr_op = matr_trans[1]
                value = matr_trans[2:end]
                __add_transform(matr_op, value, matrices)
            end
            matrices = [m[2] for m in matrices]
            if !isempty(matrices)
                transform = identity_matrix(Float64)
                for matrix in matrices
                    transform = transform * matrix
                end
                set_transform(gobject, transform)
            end
        end

        add_objects(world, gobject)
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

function __add_transform(matrix_operation, value, matrices)
    # remove entry if already exists in case
    # the transformation extends an existing one
    if matrix_operation == "translate"
        value = Float64.(value)
        __check_and_set(matrices, matrix_operation, ["translate", translation(value[1], value[2], value[3])])
    elseif matrix_operation == "scale"
        value = Float64.(value)
        __check_and_set(matrices, matrix_operation, ["scale", scaling(value[1], value[2], value[3])])
    elseif matrix_operation == "rotate-x"
        value = Float64(value[1])
        __check_and_set(matrices, matrix_operation, ["rotate-x", rotation_x(value)])
    elseif matrix_operation == "rotate-y"
        value = Float64(value[1])
        __check_and_set(matrices, matrix_operation, ["rotate-y", rotation_y(value)])
    elseif matrix_operation == "rotate-z"
        value = Float64(value[1])
        __check_and_set(matrices, matrix_operation, ["rotate-z", rotation_z(value)])
    end
end

function __check_and_set(matrices, matrix_operation, value)
    for i in 1:length(matrices)
        if matrices[i][1] == matrix_operation
            matrices[i] = value
            return
        end
    end
    # add the transformation in the first position of the array
    # because the order of the matrix multiplication is inverted
    pushfirst!(matrices,value)
end

function __array_to_ColorRGB(array)
    array = Float64.(array)
    return ColorRGB(array[1], array[2], array[3])
end

end
