module IndexShifts

export @shiftindex

using Compat
using MacroTools

_shiftindex_in_expr(ind, shift) = ind + shift
_shiftindex_in_expr(ind::AbstractVector, shift) = ind .+ shift
_shiftindex_in_expr(ind, shift::Union{Expr, Symbol}) = :($ind + $shift)
_shiftindex_in_expr(ind::Union{Expr, Symbol}, shift) = :($ind + $shift)

_shiftindex_in_ref(ref, shift) = ref
function _shiftindex_in_ref(ref::Expr, shift)
    if ref.head == :ref
        for i in 2:lastindex(ref.args)
            ref.args[i] = _shiftindex_in_expr(ref.args[i], shift)
        end
    elseif ref.head == :call && ref.args[1] == :getindex
        for i in 3:lastindex(ref.args)
            ref.args[i] = _shiftindex_in_expr(ref.args[i], shift)
        end
    end
    return ref
end

_shiftindex(blk::Expr, shift) = MacroTools.postwalk(x -> _shiftindex_in_ref(x, shift), blk)

"""

    @shiftindex [shift = 1] blk

Shift the index inside square brackets/`getindex` of `shift` positions: `a[i]`
becomes `a[i + shift]`. It can be applied even to a block of code.

# Examples
```julia-repl
julia> x = [1, 2, 3];

julia> @shiftindex x[2]
3

julia> @macroexpand @shiftindex begin
           x[0] + x[2]
           x[0:2]
       end
quote  # none, line 2:
    x[0 + 1] + x[2 + 1] # none, line 3:
    x[(0:2) + 1]
end

```
"""
macro shiftindex(shift, blk)
    return esc(_shiftindex(blk, shift))
end

macro shiftindex(blk)
    return esc(_shiftindex(blk, 1))
end

end # module
