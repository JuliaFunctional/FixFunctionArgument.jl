using FixFunctionArgument
using Test

@testset "FixFunctionArgument.jl" begin
    @testset "zero-cost abstraction for type arguments" begin
        @test (iszero ∘ sizeof ∘ Fix1)(convert, Float32)
        @test (iszero ∘ sizeof ∘ Fix2)(typeassert, Float32)
        @test (iszero ∘ sizeof ∘ Fix1)(Int, nothing)  # a call would throw, but that is not the point
    end
    @testset "`Fix1`, `Fix2`" begin
        @test Fix1 === Fix{1}
        @test Fix2 === Fix{2}
    end
    @testset "basic" begin
        @test sin(0.3) === @inferred Fix1(sin, 0.3)()
    end
end

using Aqua: Aqua

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(FixFunctionArgument)
end
