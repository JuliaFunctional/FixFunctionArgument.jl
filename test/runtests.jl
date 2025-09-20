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
        @test (7 - 3) === @inferred Fix1(-, 7)(3)
        @test (7 - 3) === @inferred Fix2(-, 3)(7)
    end
    @testset "invalid `N`" begin
        for N ∈ (-1, 0, true)
            @test_throws ArgumentError Fix{N}(+, 7)
        end
    end
    @testset "too few arguments in call" begin
        @test_throws ArgumentError Fix{10}(Returns(nothing), 7)(1, 2, 3)
    end
    @testset "instance properties" begin
        fixed = Fix1(sin, 0.3)
        @testset "`propertynames`" begin
            @test (:f, :x) === @inferred propertynames(fixed)
            @test (:f, :x) === @inferred propertynames(fixed, false)
            @test (:f, :x) === @inferred propertynames(fixed, true)
        end
        @testset "access to property that does not exist" begin
            @test_throws Exception fixed.z
        end
    end
    @testset "two-argument `show` roundtripping" begin
        for N ∈ (1, 2, 3, 999)
            for x ∈ (Fix{N}(convert, Float32), Fix{N}(Int, 7))
                @test x === (eval ∘ Meta.parse ∘ repr)(x)
            end
            let x = Fix{N}(Int, big(7))
                @test repr(x) == (repr ∘ eval ∘ Meta.parse ∘ repr)(x)
            end
        end
    end
end

using Aqua: Aqua

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(FixFunctionArgument)
end
