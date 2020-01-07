using Aether.AccelerationStructures
using Aether.CanvasModule
using Aether.Renders
using Aether.SceneImporters
using Aether.WorldModule

using Aether.BaseGeometricType: group_of
function draw_world()
    camera, lights, gobjects = import_yaml_scene_file("examples/resources/scenes/cover_scene.yml")
    scene = group_of(gobjects)
    divide!(scene,4)
    world = World()
    add_lights!(world, lights...)
    add_objects(world, scene)
    canvas = render_multithread(camera, world)
    return canvas
end

function show_scene()
    canvas = draw_world()
    show_image(canvas)
    save_image(canvas, "renders/cover_image.png")
end