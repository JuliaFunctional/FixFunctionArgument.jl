module FixFunctionArgument
    export Fix, Fix1, Fix2
    using ZeroDimensionalArrays: ZeroDimArray, ZeroDimArrayInTypeParameter
    Base.@constprop :aggressive function tuple_up_to(tuple::Tuple, n::Int)
        tuple[1:n]
    end
    Base.@constprop :aggressive function tuple_all_except_up_to(tuple::Tuple, n::Int)
        tuple[(n + 1):end]
    end
    const ZeroDArr = Union{ZeroDimArray, ZeroDimArrayInTypeParameter}
    function wrap_value(x::X) where {X}
        ZeroDimArray(x)
    end
    function wrap_value(::Type{T}) where {T}
        ZeroDimArrayInTypeParameter(T)
    end
    @noinline function throw_too_few_args()
        throw(ArgumentError("too few positional arguments given in call of a `Fix`"))
    end
    @noinline function throw_not_int()
        throw(ArgumentError("the type parameter `N` must be an `Int`"))
    end
    @noinline function throw_not_positive()
        throw(ArgumentError("the type parameter `N` must be greater than zero"))
    end
    @inline function check_positive(n)
        if !(n isa Int)
            throw_not_int()
        end
        n = n::Int
        if n < 1
            throw_not_positive()
        end
        n
    end
    """
        Fix

    A subtype of `Function`.

    `Fix{N}(f, x)` is a partially-applied version of callable `f`, with positional
    argument `x` fixed to position `N`.

    `Fix` has three type parameters:

    * `N`: an `Int`, semantics described above

    * `WrappedCallable`: depends on `f` in `Fix{N}(f, x)`

    * `WrappedFixedArgument`: depends on `x` in `Fix{N}(f, x)`

    Two properties are supported on an instance of `Fix`:

    * `f == Fix{N}(f, x).f`

    * `x == Fix{N}(f, x).x`

    `Fix` is meant to be a stand-in replacement for `Base.Fix`. Observable
    differences from `Base.Fix`:

    * `Fix` treats the case when `f isa Type` or when `x isa Type` more efficiently
      than `Base.Fix` does. In such a case, `Fix` is a zero-cost abstraction, while
      `Base.Fix` stores the type in memory at run time.

    * The second and third type parameter have:

        * different interpretations in `Fix` than in `Base.Fix`

        * different upper bounds in `Fix` than in `Base.Fix`
    """
    struct Fix{N, WrappedCallable <: ZeroDArr, WrappedFixedArgument <: ZeroDArr} <: Function
        callable::WrappedCallable
        fixed_argument::WrappedFixedArgument
        function construct(::Type{Fix{N}}, c::ZeroDArr, t::ZeroDArr) where {N}
            n = check_positive(N)
            new{n, typeof(c), typeof(t)}(c, t)
        end
        function (::Type{Fix{N}})(
            callable::Callable,
            fixed_argument::FixedArgument,
        ) where {N, Callable, FixedArgument}
            c = wrap_value(callable)
            t = wrap_value(fixed_argument)
            construct(Fix{N}, c, t)
        end
    end
    function get_n(::Fix{N}) where {N}
        check_positive(N) - 1
    end
    # Properties for compatility with `Base.Fix`
    const property_name_f = :f
    const property_name_x = :x
    function Base.propertynames((@nospecialize fix::Fix), ::Bool = false)
        (property_name_f, property_name_x)
    end
    function Base.getproperty(fix::Fix, name::Symbol)
        if name === property_name_f
            return getfield(fix, :callable)[]
        end
        if name === property_name_x
            return getfield(fix, :fixed_argument)[]
        end
        getfield(nothing, name)
    end
    # Make `Fix` callable
    function (fix::Fix)(args::Vararg{Any, TupleLength}; kwargs...) where {TupleLength}
        n = get_n(fix)
        if length(args) < n
            throw_too_few_args()
        end
        callable = fix.f
        fixed_argument = fix.x
        l = tuple_up_to(args, n)
        r = tuple_all_except_up_to(args, n)
        callable(l..., fixed_argument, r...; kwargs...)
    end
    function (fix::Fix{1})(arg; kwargs...)
        callable = fix.f
        fixed_argument = fix.x
        callable(fixed_argument, arg; kwargs...)
    end
    function (fix::Fix{2})(arg; kwargs...)
        callable = fix.f
        fixed_argument = fix.x
        callable(arg, fixed_argument; kwargs...)
    end
    """
        Fix1

    Alias for `Fix{1}`. Stand-in replacement for `Base.Fix1`.
    """
    const Fix1 = Fix{1}
    """
        Fix2

    Alias for `Fix{2}`. Stand-in replacement for `Base.Fix2`.
    """
    const Fix2 = Fix{2}
end
