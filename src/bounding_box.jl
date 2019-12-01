module AccelerationStructures

export BoundingBox,
	   box_contains_point,
	   box_contains_box,
	   bounds_of,
	   parent_space_bounds_of,
	   resize_bb!,
	   transform_bb,
	   aabb_intersect,
	   split_bounds

import Aether: ϵ
import Aether.BaseGeometricType: GeometricObject, GroupType
import Aether.HomogeneousCoordinates: point3D, vector3D, Vecf64
import Aether.MatrixTransformations: Matrix4x4
import Aether.Rays: Ray
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
	box = BoundingBox(point3D(-1., cylinder.minimum, -1.),
					  point3D(1., cylinder.maximum, 1.))
	return box
end

function bounds_of(cone::Cone)
	a = abs(cone.minimum)
	b = abs(cone.maximum)
	limit = max(a, b)

	return BoundingBox(point3D(-limit, cone.minimum, -limit),
					   point3D(limit, cone.maximum, limit))
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

function aabb_intersect(box::BoundingBox, ray::Ray)
    result = false
    xtmin, xtmax = aabb_check_axis(ray.origin.x, ray.direction.x,
								   box.min.x, box.max.x)
    ytmin, ytmax = aabb_check_axis(ray.origin.y, ray.direction.y,
								   box.min.y, box.max.y)
    ztmin, ztmax = aabb_check_axis(ray.origin.z, ray.direction.z,
								   box.min.z, box.max.z)

    tmin = max(xtmin, ytmin, ztmin)
    tmax = min(xtmax, ytmax, ztmax)
    if tmax >= tmin
        result = true
    end
    return result
end

function aabb_check_axis(origin::Float64, direction::Float64,
						 bb_min::Float64, bb_max::Float64)
    tmin_numerator = (bb_min - origin)
    tmax_numerator = (bb_max - origin)

    if abs(direction) >= ϵ
        tmin = tmin_numerator / direction
        tmax = tmax_numerator / direction
    else
        tmin = tmin_numerator * Inf
        tmax = tmax_numerator * Inf
    end

    if tmin > tmax
        tmin, tmax = tmax, tmin
    end
    return tmin, tmax
end

function split_bounds(box::BoundingBox)
	# find out the box's largest dimension
	dx = box.max.x - box.min.x
	dy = box.max.y - box.min.y
	dz = box.max.z - box.min.z

	greatest = max(dx, dy, dz)

	# variables to help construct the points on the dividing plane
	x0, y0, z0 = box.min.x, box.min.y, box.min.z
	x1, y1, z1 = box.max.x, box.max.y, box.max.z

	# adjust the point so that they lie on the dividing plane
	if greatest == dx
		x0 = x1 = x0 + dx / 2.
	elseif greatest == dy
		y0 = y1 = y0 + dy / 2.
	else
		z0 = z1 = z0 + dz / 2.
	end

	mid_min = point3D(x0, y0, z0)
	mid_max = point3D(x1, y1, z1)
	# construct and return the two halves of the bounding box
	left = BoundingBox(box.min, mid_max)
	right = BoundingBox(mid_min, box.max)
	return left, right
end

end
