using FixFunctionArgument
using Test
using Aqua

@testset "FixFunctionArgument.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(FixFunctionArgument)
    end
    # Write your tests here.
end
