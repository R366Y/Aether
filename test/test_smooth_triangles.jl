using Test
using Aether
using Aether.HomogeneousCoordinates
using Aether.Rays
using Aether.Shapes

function test_triangle()
	p1 = point3D(0., 1., 0.)
 	p2 = point3D(-1., 0., 0.)
 	p3 = point3D(1., 0., 0.)
 	n1 = vector3D(0., 1., 0.)
 	n2 = vector3D(-1., 0., 0.)
 	n3 = vector3D(1., 0., 0.)
	return smooth_triangle(p1, p2, p3, n1, n2, n3)
end

@testset "Smooth triangles" begin 
	@testset "Constructing a smooth triangle" begin
		tri = test_triangle()
		@test tri.p1 == point3D(0., 1., 0.)
	 	@test tri.p2 == point3D(-1., 0., 0.)
	 	@test tri.p3 == point3D(1., 0., 0.)
	 	@test tri.n1 == vector3D(0., 1., 0.)
	 	@test tri.n2 == vector3D(-1., 0., 0.)
	 	@test tri.n3 == vector3D(1., 0., 0.)
	end

	@testset "An intersection with a smooth triangle stores u/v" begin
		tri = test_triangle()
		r = Ray(point3D(-0.2, 0.3, -2.), vector3D(0., 0., 1.))
		xs = local_intersect(tri, r)
		@test float_equal(xs[1].u, 0.45)
		@test float_equal(xs[1].v, 0.25)
	end 
end