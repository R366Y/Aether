import Aether.BaseGeometricType: Group, add_child
import Aether.HomogeneousCoordinates: Vecf64, point3D
import Aether.Shapes: Triangle

mutable struct ObjFile
    vertices::Array{Vecf64,1}
    default_group::Group

    function ObjFile()
        new(Vecf64[], Group())
    end
end

function parse_obj_file(filepath::String)
    line_delimiters = ("v", "f")
    obj_file = ObjFile()
    open(filepath) do file
        for line in eachline(file)
            line_elements = split(line)
            first_char = line_elements[1]

            if first_char in line_delimiters
                numbers = line_elements[2:end]

                if first_char == "v"
                    if !check_if_all_numbers(numbers)
                        continue
                    end
                    process_vertices(obj_file, numbers)
                elseif first_char == "f"
                    process_faces(obj_file, numbers)
                end
            end

        end
    end
    return obj_file
end

function check_if_all_numbers(string_array)
    for s in string_array
        if !all(c->isdigit(c) || c in ('.','-'), s)
            return false
        end
    end
    return true
end

function process_vertices(obj_file, numbers)
    push!(obj_file.vertices, point3D([parse(Float64,n) for n in numbers]))
end

function process_faces(obj_file, numbers)
    vertices = [obj_file.vertices[parse(Int, n)] for n in numbers]
    t = Triangle(vertices[1], vertices[2], vertices[3])
    add_child(obj_file.default_group, t)
end
