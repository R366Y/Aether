using Test
using Aether.AccelerationStructures
using Aether.BaseGeometricType
using Aether.HomogeneousCoordinates
using Aether.MatrixTransformations
using Aether.Rays
using Aether.Shapes

@testset "Bounding box" begin

	@testset "Creating an empty bounding box" begin
		box = BoundingBox()
		@test box.min == point3D(Inf, Inf, Inf)
		@test box.max == point3D(-Inf, -Inf, -Inf)
	end

	@testset "Adding points to an empty bounding box" begin
		box = BoundingBox()
		p1 = point3D(-5., 2., 0.)
		p2 = point3D(7., 0., -3.)
		resize_bb!(box, p1)
		resize_bb!(box, p2)
		@test box.min == point3D(-5., 0., -3.)
		@test box.max == point3D(7., 2., 0.)
	end

	@testset "A sphere has a bounding box" begin
		shape = default_sphere()
		box = bounds_of(shape)
		@test box.min == point3D(-1., -1., -1.)
		@test box.max == point3D(1., 1., 1.)
	end

	@testset "A plane has a bounding box" begin
		shape = Plane()
		box = bounds_of(shape)
		@test box.min == point3D(-Inf, 0., -Inf)
		@test box.max == point3D(Inf, 0., Inf)
	end

	@testset "A cube has a bounding box" begin
		shape = Cube()
		box = bounds_of(shape)
		@test box.min == point3D(-1., -1., -1.)
		@test box.max == point3D(1., 1., 1.)
	end

	@testset "A unbounded cylinder has a bounding box" begin
		shape = Cylinder()
		box = bounds_of(shape)
		@test box.min == point3D(-1., -Inf, -1.)
		@test box.max == point3D(1., Inf, 1.)
	end

	@testset "A bounded cylinder has a bounding box" begin
		shape = Cylinder()
		shape.minimum = -5.
		shape.maximum = 3.
		box = bounds_of(shape)
		@test box.min == point3D(-1., -5., -1.)
		@test box.max == point3D(1., 3., 1.)
	end

	@testset "An unbounded conde has a bounding box" begin
		shape = Cone()
		box = bounds_of(shape)
		@test box.min == point3D(-Inf, -Inf, -Inf)
		@test box.max == point3D(Inf, Inf, Inf)
	end

	@testset "A bounded cone has a bounding box" begin
		shape = Cone()
		shape.minimum = -5.
		shape.maximum = 3.
		box = bounds_of(shape)
		@test box.min == point3D(-5., -5., -5.)
		@test box.max == point3D(5., 3., 5.)
	end

	@testset "A triangle has a bounding box" begin
		p1 = point3D(-3., 7., 2.)
		p2 = point3D(6., 2., -4.)
		p3 = point3D(2., -1., -1.)
		shape = Triangle(p1, p2, p3)
		box = bounds_of(shape)
		@test box.min == point3D(-3., -1., -4.)
		@test box.max == point3D(6., 7., 2.)
	end

	@testset "Test shape has (arbitrary) bounding box" begin
		shape = TestShape()
		box = bounds_of(shape)
		@test box.min == point3D(-1., -1., -1.)
		@test box.max == point3D(1., 1., 1.)
	end

	@testset "Adding one bounding box to another" begin
		box1 = BoundingBox(point3D(-5., -2., 0.), point3D(7., 4., 4.))
		box2 = BoundingBox(point3D(8., -7., -2.), point3D(14., 2., 8.))
		resize_bb!(box1, box2)
		@test box1.min == point3D(-5., -7., -2.)
		@test box1.max == point3D(14., 4., 8.)
	end

	@testset "Check to see if a box contains a given point" begin
		box = BoundingBox(point3D(5., -2., 0.), point3D(11., 4., 7.))

		input = NamedTuple[]
        ks = (:point, :result)
        push!(input, NamedTuple{ks}((point3D(5., -2., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(11., 4., 7.), true)) )
        push!(input, NamedTuple{ks}((point3D(8., 1., 3.), true)) )
        push!(input, NamedTuple{ks}((point3D(3., 0., 3.), false)) )
        push!(input, NamedTuple{ks}((point3D(8., -4., 3.), false)) )
        push!(input, NamedTuple{ks}((point3D(8., 1., -1.), false)) )
        push!(input, NamedTuple{ks}((point3D(13., 1., 3.), false)) )
        push!(input, NamedTuple{ks}((point3D(8., 5., 3.), false)) )
        push!(input, NamedTuple{ks}((point3D(8., 1., 8.), false)) )

        for i in input
        	p = i.point
        	@test box_contains_point(box, p) == i.result
        end
	end

	@testset "Check to see if a box contains a given point" begin
		box1 = BoundingBox(point3D(5., -2., 0.), point3D(11., 4., 7.))

		input = NamedTuple[]
        ks = (:min, :max, :result)
        push!(input, NamedTuple{ks}((point3D(5., -2., 0.), point3D(11., 4., 7.), true)) )
        push!(input, NamedTuple{ks}((point3D(6., -1., 1.), point3D(10., 3., 6.), true)) )
        push!(input, NamedTuple{ks}((point3D(4., -3., -1.),point3D(10., 3., 6.), false)) )
        push!(input, NamedTuple{ks}((point3D(6., -1., 1.),point3D(12., 5., 8.), false)) )

        for i in input
        	box2 = BoundingBox(i.min, i.max)
        	@test box_contains_box(box1, box2) == i.result
        end
	end

	@testset "Transforming a bounding box" begin
		box = BoundingBox(point3D(-1., -1., -1.), point3D(1., 1., 1.))
		matrix = rotation_x(π/4) * rotation_y(π/4)
		box2 = transform_bb(box, matrix)
		@test float_equal(box2.min, point3D(-1.41421, -1.70710, -1.70710))
		@test float_equal(box2.max, point3D(1.41421, 1.70710, 1.70710))
	end

	@testset "Querying a shape's bounding box in its parent's space" begin
		shape = default_sphere()
		set_transform(shape, translation(1., -3., 5.) * scaling(0.5, 2., 4.))
		box = parent_space_bounds_of(shape)
		@test box.min == point3D(0.5, -5., 1.)
		@test box.max == point3D(1.5, -1., 9.)
	end

	@testset "A group has a bounding box that contains its children" begin
		s = default_sphere()
		set_transform(s, translation(2., 5., -3.) * scaling(2.,2.,2.))
		c = Cylinder()
		c.minimum = -2
		c.maximum = 2
		set_transform(c, translation(-4.,-1., 4.) * scaling(0.5, 1., 0.5))
		shape = Group()
		add_child!(shape, s)
		add_child!(shape, c)
		box = bounds_of(shape)
		@test box.min == point3D(-4.5, -3., -5.)
		@test box.max == point3D(4., 7., 4.5)
	end

	@testset "Intersecting a ray with a bounding box at the origin" begin
		box = BoundingBox(point3D(-1., -1., -1.), point3D(1., 1., 1.))

		input = NamedTuple[]
        ks = (:origin, :direction, :result)
        push!(input, NamedTuple{ks}((point3D(5., 0.5, 0.), vector3D(-1., 0., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(-5., 0.5, 0.), vector3D(1., 0., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(0.5, 5., 0.), vector3D(0., -1., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(0.5, -5., 0.), vector3D(0., 1., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(0.5, 0., 5.), vector3D(0., 0., -1.), true)) )
        push!(input, NamedTuple{ks}((point3D(0.5, 0., -5.), vector3D(0., 0., 1.), true)) )
        push!(input, NamedTuple{ks}((point3D(0., 0.5, 0.), vector3D(0., 0., 1.), true)) )
        push!(input, NamedTuple{ks}((point3D(-2., 0., 0.), vector3D(2., 4., 6.), false)) )
        push!(input, NamedTuple{ks}((point3D(0., -2., 0.), vector3D(6., 2., 4.), false)) )
        push!(input, NamedTuple{ks}((point3D(0., 0., -2.), vector3D(4., 6., 2.), false)) )
        push!(input, NamedTuple{ks}((point3D(2., 0., 2.), vector3D(0., 0., -1.), false)) )
        push!(input, NamedTuple{ks}((point3D(0., 2., 2.), vector3D(0., -1., 0.), false)) )
        push!(input, NamedTuple{ks}((point3D(2., 2., 0.), vector3D(-1., 0., 0.), false)) )

		for i in input
			direction = normalize(i.direction)
			r = Ray(i.origin, direction)
			@test aabb_intersect(box, r) == i.result
		end
	end

	@testset "Intersecting a ray with a non-cubic bounding box" begin
		box = BoundingBox(point3D(5., -2., 0.), point3D(11., 4., 7.))

		input = NamedTuple[]
        ks = (:origin, :direction, :result)
        push!(input, NamedTuple{ks}((point3D(15., 1., 2.), vector3D(-1., 0., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(-5., -1., 4.), vector3D(1., 0., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(7., 6., 5.), vector3D(0., -1., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(9., -5., 6.), vector3D(0., 1., 0.), true)) )
        push!(input, NamedTuple{ks}((point3D(8., 2., 12.), vector3D(0., 0., -1.), true)) )
        push!(input, NamedTuple{ks}((point3D(6., 0., -5.), vector3D(0., 0., 1.), true)) )
        push!(input, NamedTuple{ks}((point3D(8., 1., 3.5), vector3D(0., 0., 1.), true)) )
        push!(input, NamedTuple{ks}((point3D(9., -1., -8.), vector3D(2., 4., 6.), false)) )
        push!(input, NamedTuple{ks}((point3D(8., 3., -4.), vector3D(6., 2., 4.), false)) )
        push!(input, NamedTuple{ks}((point3D(9., -1., -2.), vector3D(4., 6., 2.), false)) )
        push!(input, NamedTuple{ks}((point3D(4., 0., 9.), vector3D(0., 0., -1.), false)) )
        push!(input, NamedTuple{ks}((point3D(8., 6., -1.), vector3D(0., -1., 0.), false)) )
        push!(input, NamedTuple{ks}((point3D(12., 5., 4.), vector3D(-1., 0., 0.), false)) )

		for i in input
			direction = normalize(i.direction)
			r = Ray(i.origin, direction)
			@test aabb_intersect(box, r) == i.result
		end
	end

	@testset "Intersecting ray+group doesn't test children if box is missed" begin
		child = TestShape()
		shape = Group()
		add_child!(shape, child)
		r = Ray(point3D(0., 0., -5.), vector3D(0., 1., 0.))
		xs = r_intersect(shape, r)
		@test isnothing(child.saved_ray)
	end

	@testset "Intersect ray+group tests children if box is hit" begin
		child = TestShape()
		shape = Group()
		add_child!(shape, child)
		r = Ray(point3D(0., 0., -5.), vector3D(0., 0., 1.))
		xs = r_intersect(shape, r)
		@test !isnothing(child.saved_ray)
	end

	@testset "Splitting a perfect cube" begin
		box = BoundingBox(point3D(-1., -4., -5.), point3D(9., 6., 5.))
		left, right = split_bounds(box)
		@test left.min == point3D(-1., -4., -5.)
		@test left.max == point3D(4., 6., 5.)
		@test right.min == point3D(4., -4., -5.)
		@test right.max == point3D(9., 6., 5.)
	end

	@testset "Splitting an x-wide box" begin
		box = BoundingBox(point3D(-1., -2., -3.), point3D(9., 5.5, 3.))
		left, right = split_bounds(box)
		@test left.min == point3D(-1., -2., -3.)
		@test left.max == point3D(4., 5.5, 3.)
		@test right.min == point3D(4., -2., -3.)
		@test right.max == point3D(9., 5.5, 3.)
	end

	@testset "Splitting an y-wide box" begin
		box = BoundingBox(point3D(-1., -2., -3.), point3D(5., 8., 3.))
		left, right = split_bounds(box)
		@test left.min == point3D(-1., -2., -3.)
		@test left.max == point3D(5., 3., 3.)
		@test right.min == point3D(-1., 3., -3.)
		@test right.max == point3D(5., 8., 3.)
	end

	@testset "Splitting an z-wide box" begin
		box = BoundingBox(point3D(-1., -2., -3.), point3D(5., 3., 7.))
		left, right = split_bounds(box)
		@test left.min == point3D(-1., -2., -3.)
		@test left.max == point3D(5., 3., 2.)
		@test right.min == point3D(-1., -2., 2.)
		@test right.max == point3D(5., 3., 7.)
	end

	@testset "Partitioning a group's children" begin
		s1 = default_sphere()
		set_transform(s1, translation(-2., 0., 0.))
		s2 = default_sphere()
		set_transform(s2, translation(2., 0., 0.))
		s3 = default_sphere()
		g = Group()
		add_child!(g, s1)
		add_child!(g, s2)
		add_child!(g, s3)
		left, right = partition_children!(g)
		@test length(g.shapes) == 1
		@test s3 in g.shapes
		@test left == [s1]
		@test right == [s2]
	end

	@testset "Subdividing a primitive does nothing" begin
		shape = default_sphere()
		divide!(shape, 1)
		@test typeof(shape) == Sphere
	end

	@testset "Subdividing a group partitions its children" begin
		s1 = default_sphere()
		set_transform(s1, translation(-2., -2., 0.))
		s2 = default_sphere()
		set_transform(s2, translation(-2., 2., 0.))
		s3 = default_sphere()
		set_transform(s3, scaling(4., 4., 4.))
		g = Group()
		for child in [s1, s2, s3]
			add_child!(g, child)
		end
		divide!(g, 1)
		@test g.shapes[1] == s3
		subgroup = g.shapes[2]
		@test typeof(subgroup) <: GroupType
		@test length(subgroup.shapes) == 2
		@test subgroup.shapes[1].shapes == [s1]
		@test subgroup.shapes[2].shapes == [s2]
	end
end
