module AccelerationStructures

export BoundingBox, 
	   box_contains_point, 
	   box_contains_box, 
	   bounds_of, 
	   parent_space_bounds_of, 
	   resize_bb!, 
	   transform_bb 

import Aether.BaseGeometricType: GeometricObject, GroupType
import Aether.HomogeneousCoordinates: point3D, vector3D, Vecf64
import Aether.MatrixTransformations: Matrix4x4
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

function resize_bb!(box1::BoundingBox, box2::BoundingBox)
	resize_bb!(box1, box2.min)
	resize_bb!(box1, box2.max)
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

function bounds_of(test_shape::TestShape)
	return BoundingBox(point3D(-1., -1., -1.), point3D(1., 1., 1.))
end

function bounds_of(group::GroupType)
	box = BoundingBox()

	for child in group.shapes
		cbox = parent_space_bounds_of(child)
		resize_bb!(box, cbox)
	end
	return box
end

function box_contains_point(box::BoundingBox, point::Vecf64)
	return  box.min.x <= point.x <= box.max.x &&
			box.min.y <= point.y <= box.max.y &&
			box.min.z <= point.z <= box.max.z
end

function box_contains_box(box1::BoundingBox, box2::BoundingBox)
	return box_contains_point(box1, box2.min) &&
		   box_contains_point(box1, box2.max)
end

function transform_bb(box::BoundingBox, matrix::Matrix4x4)
	p1 = box.min 
	p2 = point3D(box.min.x, box.min.y, box.max.z)
	p3 = point3D(box.min.x, box.max.y, box.min.z)
	p4 = point3D(box.min.x, box.max.y, box.max.z)
	p5 = point3D(box.max.x, box.min.y, box.min.z)
	p6 = point3D(box.max.x, box.min.y, box.max.z)
	p7 = point3D(box.max.x, box.max.y, box.min.z)
	p8 = box.max

	new_box = BoundingBox()
	for p in (p1, p2, p3, p4, p5, p6, p7, p8)
		t_p = matrix * p 
		resize_bb!(new_box, t_p)
	end
	return new_box
end

function parent_space_bounds_of(shape::GeometricObject)
	return transform_bb(bounds_of(shape), shape.transform)
end

end