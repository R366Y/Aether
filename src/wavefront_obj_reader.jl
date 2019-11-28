import Aether.BaseGeometricType: Group, add_child
import Aether.HomogeneousCoordinates: Vecf64, point3D, vector3D
import Aether.Shapes: Triangle, SmoothTriangle

mutable struct ObjFile
    vertices::Array{Vecf64,1}
    normals::Array{Vecf64,1}
    default_group::Group
    named_groups::Dict
    active_group::Group

    function ObjFile()
        g = Group()
        new(Vecf64[], Vecf64[], g, Dict(), g)
    end
end

function add_new_named_group(name, obj_file)
    obj_file.active_group = Group()
    obj_file.named_groups[name] = obj_file.active_group
end

function parse_obj_file(filepath::String)
    line_delimiters = ("v", "vn", "f", "g")
    obj_file = ObjFile()
    open(filepath) do file
        for line in eachline(file)
            line_elements = split(line)
            if length(line_elements) == 0
                continue
            end
            first_char = line_elements[1]

            if first_char in line_delimiters
                tokens = line_elements[2:end]
                parse_tokens(obj_file, first_char, tokens)
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

function parse_tokens(obj_file, first_char, tokens)
    if first_char == "v"
        if !check_if_all_numbers(tokens)
            return
        end
        parse_vertices(obj_file, tokens)
    elseif first_char == "vn"
        if !check_if_all_numbers(tokens)
            return
        end
        parse_normals(obj_file, tokens)
    elseif first_char == "f"
        vertices, tex, normals = parse_faces(tokens)
        if !check_if_all_numbers(vertices)
            return
        end
        # f parameter describes a triangle
        if length(vertices) == 3
            parse_faces_vertices(obj_file, vertices, normals)
        # f parameter describes a polygon
        elseif length(vertices) > 3
            fan_triangulation(obj_file, vertices, normals)
        end
    elseif first_char == "g"
        # g parameter describes a named group
        add_new_named_group(String(join(tokens)), obj_file)
    end
end

function check_if_all_numbers(string_array)
    for s in string_array
        if !all(c -> isdigit(c) || c in ('.', '-'), s)
            return false
        end
    end
    return true
end

function parse_vertices(obj_file, coordinates)
    push!(obj_file.vertices, point3D([parse(Float64, n) for n in coordinates]))
end

function parse_normals(obj_file, coordinates)
    push!(obj_file.normals, vector3D([parse(Float64, n) for n in coordinates]))
end

function parse_faces(tokens)
    vertices = []
    tex = []
    normals = []
    for token in tokens
        face_attributes = [c for c in split(token, "/") if !isempty(c)]
        la = length(face_attributes)
        push!(vertices, face_attributes[1])
        if la == 2
            push!(normals, face_attributes[2])
        elseif la > 2
            push!(tex, face_attributes[2])
            push!(normals, face_attributes[3])
        end
    end
    return vertices, tex, normals
end

function parse_faces_vertices(obj_file, vertex_numbers, normals)
    face_vertices = [obj_file.vertices[parse(Int, v)] for v in vertex_numbers]
    if isempty(normals)
        t = Triangle(face_vertices[1], face_vertices[2], face_vertices[3])
    else 
        face_normals = [obj_file.normals[parse(Int, n)] for n in normals]
        t = SmoothTriangle(face_vertices[1], face_vertices[2], face_vertices[3],
                           face_normals[1], face_normals[2], face_normals[3])
    end
    add_child(obj_file.active_group, t)
end

function fan_triangulation(obj_file, vertex_numbers, normals)
    face_vertices = [obj_file.vertices[parse(Int, v)] for v in vertex_numbers]
    for index in 2:length(vertex_numbers) - 1
        if isempty(normals)
            tri = Triangle(face_vertices[1], face_vertices[index], face_vertices[index + 1])
        else 
            face_normals = [obj_file.normals[parse(Int, n)] for n in normals]
            tri = SmoothTriangle(face_vertices[1], face_vertices[index], face_vertices[index + 1],
                                 face_normals[1], face_normals[index], face_normals[index + 1])
        end
        add_child(obj_file.active_group, tri)
    end
end
