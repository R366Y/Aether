using Test
using Aether.BaseGeometricType
using Aether.CSolidGeometry
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
end