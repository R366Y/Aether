module Renders

export render, render_multithread

using Base.Threads
using LinearAlgebra
using ProgressMeter

using Aether.CameraModule
using Aether.CanvasModule
using Aether.WorldModule

function render(camera::Camera, world::World, progress_meter = true)
    image = empty_canvas(camera.hsize, camera.vsize)
    p = Progress(camera.hsize * camera.vsize)
    for x = 1:camera.hsize
        for y = 1:camera.vsize
            ray = ray_for_pixel(camera, x, y)
            color = color_at(world, ray, 5)
            write_pixel!(image, x, y, color)
            if progress_meter
                ProgressMeter.next!(p)
            end
        end
    end
    return image
end

function render_multithread(camera::Camera, world::World, progress_meter = true)
    # Initialize the progress bar
    p = Progress(camera.hsize * camera.vsize)
    update!(p, 0)
    jj = Threads.Atomic{Int}(0)
    # Setting the number of BLAS threads to 1 so they do not interfere
    # with our threads
    BLAS.set_num_threads(1)

    # divide the horizontal size of our image by the number of threads
    # and save also the reminder
    len, rem = divrem(camera.hsize, nthreads())
    image = empty_canvas(camera.hsize, camera.vsize)

    #Split the image equally among the threads
    num_threads = nthreads()
    sub_images = []
    for t = 1:num_threads
        push!(sub_images, empty_canvas(len, camera.vsize))
    end

    # map every subimage to a given thread
    @threads for t = 1:num_threads
        sub_image = sub_images[t]
        n = 1
        for x = t:num_threads:camera.hsize-rem
            for y = 1:camera.vsize
                ray = ray_for_pixel(camera, x, y)
                color = color_at(world, ray, 5)
                write_pixel!(sub_image, n, y, color)
                if progress_meter
                    Threads.atomic_add!(jj, 1)
                    Threads.threadid() == 1 && update!(p, jj[])
                end
            end
            n += 1
        end
    end

    # process the remaining data in case the image width is not an
    # even number
    remaining = camera.hsize - rem
    remaining_subimage = empty_canvas(rem, camera.vsize)
    for x = remaining+1:camera.hsize
        for y = 1:camera.vsize
            ray = ray_for_pixel(camera, x, y)
            color = color_at(world, ray, 5)
            write_pixel!(remaining_subimage, x - remaining, y, color)
            if progress_meter
                Threads.atomic_add!(jj, 1)
                update!(p, jj[])
            end
        end
    end

    if progress_meter
        ProgressMeter.finish!(p)
    end
    BLAS.set_num_threads(num_threads)

    # recombine the subimages into a single image
    for t = 1:num_threads
        sub_image = sub_images[t]
        n = 1
        for x = t:num_threads:camera.hsize-rem
            image.__data[:, x] .= sub_image.__data[:, n]
            n += 1
        end
    end
    image.__data[:, remaining+1:camera.hsize] .= remaining_subimage.__data

    return image
end

end