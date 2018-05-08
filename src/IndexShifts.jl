module IndexShifts

export @shiftindex

using Compat
using MacroTools

_shiftindex_expr(x, shift) = x
function _shiftindex_expr(x::Expr, shift)
    if x.head == :ref
        for i in 2:lastindex(x.args)
            x.args[i] = :($(x.args[i]) + $shift)
        end
    elseif x.head == :call && x.args[1] == :getindex
        for i in 3:lastindex(x.args)
            x.args[i] = :($(x.args[i]) + $shift)
        end
    end
    return x
end

_shiftindex(blk::Expr, shift) = MacroTools.postwalk(x -> _shiftindex_expr(x, shift), blk)

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
