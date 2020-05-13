using Aether.CanvasModule
using Aether.Renders
using Aether.SceneImporters
using Aether.WorldModule

function draw_world()
    camera, lights, gobjects = import_yaml_scene_file("examples/resources/scenes/puppets.yml")
    world = World()
    add_lights!(world, lights...)
    add_objects(world, gobjects...)
    canvas = render_multithread(camera, world)
    return canvas
end

function show_scene()
    canvas = draw_world()
    save_image(canvas, "renders/puppets.png")
    show_image_with_default_reader(joinpath("renders", "puppets.png"))
end
