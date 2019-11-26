using Test
using Aether
using Aether.BaseGeometricType
using Aether.ComputationsModule
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
	return SmoothTriangle(p1, p2, p3, n1, n2, n3)
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

	@testset "A smooth triangle uses u/v to interpolate the normal" begin
		tri = test_triangle()
		i = Intersection(1., tri, 0.45, 0.25)
		n = normal_at(tri, point3D(0., 0., 0.), i.u, i.v)
		@test float_equal(n, vector3D(-0.5547, 0.83205, 0.))
	end

	@testset "Preparing the normal on a smooth triangle" begin
		tri = test_triangle()
		i = Intersection(1., tri, 0.45, 0.25)
		r = Ray(point3D(-0.2, 0.3, -2.), vector3D(0., 0., 1.))
		xs = Intersection[i]
		comps = prepare_computations(i, r, xs)
		@test float_equal(comps.normalv, vector3D(-0.5547, 0.83205, 0.))
	end
end