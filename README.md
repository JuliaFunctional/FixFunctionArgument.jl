# FixFunctionArgument

[![Build Status](https://github.com/JuliaFunctional/FixFunctionArgument.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaFunctional/FixFunctionArgument.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Package version](https://juliahub.com/docs/General/FixFunctionArgument/stable/version.svg)](https://juliahub.com/ui/Packages/General/FixFunctionArgument)
[![Package dependencies](https://juliahub.com/docs/General/FixFunctionArgument/stable/deps.svg)](https://juliahub.com/ui/Packages/General/FixFunctionArgument?t=2)
[![Coverage](https://codecov.io/gh/JuliaFunctional/FixFunctionArgument.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaFunctional/FixFunctionArgument.jl)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/F/FixFunctionArgument.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/F/FixFunctionArgument.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A Julia package for fixing a given positional argument to a given callable. Intended as a straight improvement upon and stand-in replacement for `Base.Fix` (including `Base.Fix1` and `Base.Fix2`).

## Provided functionality

The package exports the following bindings:

* `Fix`

* `Fix1`

* `Fix2`

The usage is the same as with the `Base` counterparts.

## Motivation

`Base.Fix` fails to be a zero-cost abstraction when the provided callable or the provided argument to fix are types. `Fix` handles that case as expected:

```julia-repl
julia> sizeof(Base.Fix1(convert, Float32))
8

julia> using FixFunctionArgument

julia> sizeof(Fix1(convert, Float32))
0
```

Here is a more concrete, albeit artificial, example of a performance difference between `Fix` and `Base.Fix`.

```julia
# calls `f` eight times
function iterated_function_8(f::Func, x) where {Func}
    f = f ∘ f
    f = f ∘ f
    f = f ∘ f
    f(x)
end

# like `identity`, but should not inline
@noinline function identity_noinline(x)
    x
end

# only does calling, for benchmarking call/stack overhead
function identity_noinline_iterated(x)
    iterated_function_8(identity_noinline, x)
end

using BenchmarkTools, FixFunctionArgument

x = Fix1(convert, Float32)
y = Base.Fix1(convert, Float32)

@btime identity_noinline_iterated($x)     #  1.292 ns (0 allocations: 0 bytes)
@btime identity_noinline_iterated($y)     # 16.222 ns (1 allocation: 16 bytes)

@code_typed identity_noinline_iterated(x)  # shows that the entire call gets constant folded away
```

Interpretation: for `Fix`, unlike for `Base.Fix`, the `identity_noinline_iterated` call has zero cost, because the entire call gets constant folded away.
