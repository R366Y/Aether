using Aether.CanvasModule
using Aether.Renders
using Aether.SceneImporters

function draw_world()
    camera, world = import_yaml_scene_file("examples/resources/scenes/world_scene.yaml")
    canvas = render(camera, world)
    return canvas
end

function show_scene()
    canvas = draw_world()
    show_image(canvas)
end