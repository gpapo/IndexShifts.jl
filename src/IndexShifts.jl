module IndexShifts

export @shiftindex

using Compat
using MacroTools

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
