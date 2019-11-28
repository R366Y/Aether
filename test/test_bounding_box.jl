using Test 
using Aether.AccelerationStructures
using Aether.HomogeneousCoordinates
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
		box = bound_of(shape)
		@test box.min == point3D(-1., -1., -1.)
		@test box.max == point3D(1., 1., 1.)
	end

	@testset "A plane has a bounding box" begin
		shape = Plane()
		box = bound_of(shape)
		@test box.min == point3D(-Inf, 0., -Inf)
		@test box.max == point3D(Inf, 0., Inf)
	end	

	@testset "A cube has a bounding box" begin
		shape = Cube()
		box = bound_of(shape)
		@test box.min == point3D(-1., -1., -1.)
		@test box.max == point3D(1., 1., 1.)
	end

	@testset "A unbounded cylinder has a bounding box" begin
		shape = Cylinder()
		box = bound_of(shape)
		@test box.min == point3D(-1., -Inf, -1.)
		@test box.max == point3D(1., Inf, 1.)
	end	

	@testset "A bounded cylinder has a bounding box" begin
		shape = Cylinder()
		shape.minimum = -5
		shape.maximum = 3
		box = bound_of(shape)
		@test box.min == point3D(-1., -5., -1.)
		@test box.max == point3D(1., 3., 1.)
	end
end