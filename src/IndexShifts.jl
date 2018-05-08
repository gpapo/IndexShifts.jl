module IndexShifts

export @shiftindex

using Compat
using MacroTools

"""

    @shiftindex shift blk

Shift the index inside square brackets/`getindex` of `shift` positions: `a[i]`
becomes `a[i + shift]`. It can be applied even to a block of code.

# Examples
```julia-repl
julia> x = [1, 2, 3];

julia> @shiftindex 1 x[2]
3

julia> @macroexpand @shiftindex 1 begin
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
    return esc(MacroTools.postwalk(blk) do x
        if isa(x, Expr)
            if x.head == :ref
                for i in 2:lastindex(x.args)
                    x.args[i] = :($(x.args[i]) + $shift)
                end
            elseif x.head == :call && x.args[1] == :getindex
                for i in 3:lastindex(x.args)
                    x.args[i] = :($(x.args[i]) + $shift)
                end
            end
        end
        return x
    end)
end

end # module
