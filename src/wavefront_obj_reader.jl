import Aether.BaseGeometricType: Group, add_child
import Aether.HomogeneousCoordinates: Vecf64, point3D
import Aether.Shapes: Triangle

mutable struct ObjFile
    vertices::Array{Vecf64,1}
    default_group::Group
    named_groups::Dict
    active_group::Group

    function ObjFile()
        g = Group()
        new(Vecf64[], g, Dict(), g)
    end
end

function add_new_named_group(name, obj_file)
    obj_file.active_group = Group()
    obj_file.named_groups[name] = obj_file.active_group
end

function parse_obj_file(filepath::String)
    line_delimiters = ("v", "f", "g")
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
                    # f parameter describes a triangle
                    if length(numbers) == 3
                        process_faces(obj_file, numbers)
                    # f parameter describes a polygon
                    elseif length(numbers) > 3
                        fan_triangulation(obj_file, numbers)
                    end
                elseif first_char == "g"
                    # g parameter describes a named group
                    add_new_named_group(String(join(numbers)), obj_file)
                end
            end
        end
    end
    return obj_file
end

function obj_to_group(obj_file)
    g = deepcopy(obj_file.default_group)
    for k in keys(obj_file.named_groups)
        add_child(g, obj_file.named_groups[k])
    end
    return g
end

function check_if_all_numbers(string_array)
    for s in string_array
        if !all(c -> isdigit(c) || c in ('.', '-'), s)
            return false
        end
    end
    return true
end

function process_vertices(obj_file, coordinates)
    push!(obj_file.vertices, point3D([parse(Float64, n) for n in coordinates]))
end

function process_faces(obj_file, vertex_numbers)
    vertices = [obj_file.vertices[parse(Int, v)] for v in vertex_numbers]
    t = Triangle(vertices[1], vertices[2], vertices[3])
    add_child(obj_file.active_group, t)
end

function fan_triangulation(obj_file, vertex_numbers)
    for index in 2:length(vertex_numbers) - 1
        tri = Triangle(obj_file.vertices[1],
                       obj_file.vertices[parse(Int, vertex_numbers[index])],
                       obj_file.vertices[parse(Int, vertex_numbers[index + 1])]
                       )
        add_child(obj_file.active_group, tri)
    end
end
