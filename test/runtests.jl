using FixFunctionArgument
using Test

@testset "FixFunctionArgument.jl" begin
    # Write your tests here.
end

using Aqua: Aqua

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(FixFunctionArgument)
end
