using Test
using Aether.BaseGeometricType
using Aether.CSolidGeometry
using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
using Aether.Rays
using Aether.Shapes

@testset "CSG" begin
    @testset "CSG is created with an operation and two shapes" begin
        s1 = default_sphere()
        s2 = Cube()
        c = CSG(csg_union_op, s1, s2)
        @test c.operation == csg_union_op
        @test c.left == s1
        @test c.right == s2
        @test s1.parent == c
        @test s2.parent == c
    end

    @testset "Evaluating the rule for a CSG operation" begin    
        input = NamedTuple[]
        ks = (:operation, :lhit, :inl, :inr, :result)
        push!(input, NamedTuple{ks}((csg_union_op, true, true, true, false)))
        push!(input, NamedTuple{ks}((csg_union_op, true, true, false, true)))
        push!(input, NamedTuple{ks}((csg_union_op, true, false, true, false)))
        push!(input, NamedTuple{ks}((csg_union_op, true, false, false, true)))
        push!(input, NamedTuple{ks}((csg_union_op, false, true, true, false)))
        push!(input, NamedTuple{ks}((csg_union_op, false, true, false, false)))
        push!(input, NamedTuple{ks}((csg_union_op, false, false, true, true)))
        push!(input, NamedTuple{ks}((csg_union_op, false, false, false, true)))

        push!(input, NamedTuple{ks}((csg_intersect_op, true, true, true, true)))
        push!(input, NamedTuple{ks}((csg_intersect_op, true, true, false, false)))
        push!(input, NamedTuple{ks}((csg_intersect_op, true, false, true, true)))
        push!(input, NamedTuple{ks}((csg_intersect_op, true, false, false, false)))
        push!(input, NamedTuple{ks}((csg_intersect_op, false, true, true, true)))
        push!(input, NamedTuple{ks}((csg_intersect_op, false, true, false, true)))
        push!(input, NamedTuple{ks}((csg_intersect_op, false, false, true, false)))
        push!(input, NamedTuple{ks}((csg_intersect_op, false, false, false, false)))

        push!(input, NamedTuple{ks}((csg_difference_op, true, true, true, false)))
        push!(input, NamedTuple{ks}((csg_difference_op, true, true, false, true)))
        push!(input, NamedTuple{ks}((csg_difference_op, true, false, true, false)))
        push!(input, NamedTuple{ks}((csg_difference_op, true, false, false, true)))
        push!(input, NamedTuple{ks}((csg_difference_op, false, true, true, true)))
        push!(input, NamedTuple{ks}((csg_difference_op, false, true, false, true)))
        push!(input, NamedTuple{ks}((csg_difference_op, false, false, true, false)))
        push!(input, NamedTuple{ks}((csg_difference_op, false, false, false, false)))

        for i in input 
            @test i.result == intersection_allowed(i.operation, i.lhit, i.inl, i.inr)
        end
    end

    @testset "Filtering a list of intersections" begin
        s1 = default_sphere()
        s2 = Cube()
        input = NamedTuple[]
        ks = (:operation, :x0, :x1)
        push!(input, NamedTuple{ks}((csg_union_op, 1, 4)))
        push!(input, NamedTuple{ks}((csg_intersect_op, 2, 3)))
        push!(input, NamedTuple{ks}((csg_difference_op, 1, 2)))
        for i in input
            c = CSG(i.operation, s1, s2)
            xs = Intersection[Intersection(1., s1), Intersection(2., s2), Intersection(3., s1), Intersection(4., s2)]
            result = filter_intersections(c, xs)
            @test length(result) == 2
            @test result[1] == xs[i.x0]
            @test result[2] == xs[i.x1]
        end
    end

    @testset "Filtering a list of intersections in a group" begin
        s1 = default_sphere()
        s2 = Cube()
        s3 = Cone()
        g = Group()
        add_child!(g, s1)
        add_child!(g, s3)
        input = NamedTuple[]
        ks = (:operation, :x0, :x1)
        push!(input, NamedTuple{ks}((csg_union_op, 1, 4)))
        push!(input, NamedTuple{ks}((csg_intersect_op, 2, 3)))
        push!(input, NamedTuple{ks}((csg_difference_op, 1, 2)))
        for i in input
            c = CSG(i.operation, g, s2)
            xs = Intersection[Intersection(1., s1), Intersection(2., s2), Intersection(3., s1), Intersection(4., s2)]
            result = filter_intersections(c, xs)
            @test length(result) == 2
            @test result[1] == xs[i.x0]
            @test result[2] == xs[i.x1]
        end
    end

    @testset "A ray missed a CSG object" begin
        c = CSG(csg_union_op, default_sphere(), Cube())
        r = Ray(point3D(0., -2., -5.), vector3D(0., 0., 1.))
        xs = local_intersect(c, r)
        @test isempty(xs)
    end

    @testset "A ray hits a CSG object" begin
        s1 = default_sphere()
        s2 = default_sphere()
        set_transform(s2, translation(0., 0., 0.5))
        c = CSG(csg_union_op, s1, s2)
        r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
        xs = local_intersect(c, r)
        @test length(xs) == 2
        @test xs[1].t == 4.
        @test xs[1].gobject == s1
        @test xs[2].t == 6.5
        @test xs[2].gobject == s2
    end
end