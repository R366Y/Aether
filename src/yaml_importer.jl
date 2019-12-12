module SceneImporters

import YAML

function import_yaml_scene_file(filename::String)

end

function read_camera_data(yaml_data::Dict)

end

macro string_as_varname_macro(s::AbstractString, v::Any)
	s = Symbol(s)
	esc(:($s = $v))
end

end