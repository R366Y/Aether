module AccelerationStructures

export BoundingBox, bounds_of, resize_bb!

import Aether.HomogeneousCoordinates: point3D, vector3D, Vecf64
import Aether.Shapes: Cone,
				      Cube,
				      Cylinder,
				      Plane,
				      Sphere,
				      TriangleType,
				      TestShape

mutable struct BoundingBox 
	min::Vecf64
	max::Vecf64

	BoundingBox() = new(point3D(Inf, Inf, Inf), point3D(-Inf, -Inf, -Inf))
	BoundingBox(minimum::Vecf64, maximum::Vecf64) = new(minimum, maximum)
end

function resize_bb!(box::BoundingBox, point::Vecf64)
	point.x < box.min.x ? box.min.x = point.x : nothing
	point.y < box.min.y ? box.min.y = point.y : nothing
	point.z < box.min.z ? box.min.z = point.z : nothing

	point.x > box.max.x ? box.max.x = point.x : nothing
	point.y > box.max.y ? box.max.y = point.y : nothing
	point.z > box.max.z ? box.max.z = point.z : nothing
end

function bounds_of(sphere::Sphere)
	box = BoundingBox(point3D(-1., -1., -1.), point3D(1., 1., 1.))
	return box
end

function bounds_of(plane::Plane)
	box = BoundingBox(point3D(-Inf, 0., -Inf), point3D(Inf, 0., Inf))
	return box
end

function bounds_of(cube::Cube)
	box = BoundingBox(point3D(-1., -1., -1.), point3D(1., 1., 1.))
	return box
end

function bounds_of(cylinder::Cylinder)
	box = BoundingBox(point3D(-1., cylinder.minimum, -1.), point3D(1., cylinder.maximum, 1.))
	return box
end

function bounds_of(cone::Cone)
	a = abs(cone.minimum)
	b = abs(cone.maximum)
	limit = max(a, b)

	return BoundingBox(point3D(-limit, cone.minimum, -limit), point3D(limit, cone.maximum, limit))
end

function bounds_of(triangle::TriangleType)
	box = BoundingBox()
	resize_bb!(box, triangle.p1)
	resize_bb!(box, triangle.p2)
	resize_bb!(box, triangle.p3)
	return box
end

end