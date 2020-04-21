# define and extend accessors
has_extend(yaml_document::Dict) = haskey(yaml_document,"extend")
has_define(yaml_document::Dict) = haskey(yaml_document,"define")
yaml_define(yaml_document::Dict) = yaml_document["define"]
yaml_extend(yaml_document::Dict) = yaml_document["extend"]
yaml_value(yaml_document::Dict) = yaml_document["value"]

# accessors to camera parameters in yaml document
yaml_camera_data(yaml_document::Dict) = yaml_document["camera"]
yaml_camera_width(yaml_camera_data::Dict) = Int(yaml_camera_data["width"])
yaml_camera_height(yaml_camera_data::Dict) = Int(yaml_camera_data["height"])
yaml_camera_fov(yaml_camera_data::Dict) = Float64(yaml_camera_data["field-of-view"])
yaml_camera_from(yaml_camera_data::Dict) = Float64.(yaml_camera_data["from"])
yaml_camera_to(yaml_camera_data::Dict) = Float64.(yaml_camera_data["to"])
yaml_camera_up(yaml_camera_data::Dict) = Float64.(yaml_camera_data["up"])

# accessors to lights parameters in yaml document
yaml_lights_data(yaml_document::Dict) = yaml_document["lights"]
yaml_lights_intensity(yaml_lights_data::Dict) = Float64.(yaml_lights_data["intensity"])
yaml_lights_at(yaml_lights_data::Dict) = Float64.(yaml_lights_data["at"])

# accessor to materials in yaml document
has_predefined_materials(yaml_document::Dict) = haskey(yaml_document, "materials")
yaml_materials_data(yaml_document::Dict) = yaml_document["materials"]

# accessors to transforms in yaml document
has_transforms(yaml_document::Dict) = haskey(yaml_document, "transforms")
yaml_transforms_data(yaml_document::Dict) = yaml_document["transforms"]

# accessors to gobjects in yaml document
yaml_gobject_data(yaml_document::Dict) = yaml_document["gobjects"]

