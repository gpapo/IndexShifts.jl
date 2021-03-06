# IndexShifts

[![Build Status](https://travis-ci.org/gpapo/IndexShifts.jl.svg?branch=master)](https://travis-ci.org/gpapo/IndexShifts.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/87w3oyf4sec97si3?svg=true)](https://ci.appveyor.com/project/gpapo/indexshifts-jl)

Often working with 1-indexed vectors leads to ugly corrections inside squared brackets, with `+1`
rising everywhere in the code.

However, maybe using [OffsetArrays.jl](https://github.com/JuliaArrays/OffsetArrays.jl)
and similar packages (with all the complications that this entails) is a bit an overkill for a small chunk of code.

This very basic package aims to simplify life exporting a macro that does the work of adding the `+ 1` or more general `+ shift` for you.

```julia
julia> using IndexShifts

julia> x = [1, 2, 3];

julia> @shiftindex x[1]
2

julia> @macroexpand @shiftindex x[1]
:(x[1 + 1])

julia> @shiftindex x[1] x[1]
2

julia> @macroexpand @shiftindex x[1] x[1]
:(x[1 + x[1]])

julia> @macroexpand @shiftindex begin
       x[1:2] .+ x[1]
       x[2] * x[1]
       end
quote  # none, line 2:
    x[(1:2) + 1] .+ x[1 + 1] # none, line 3:
    x[2 + 1] * x[1 + 1]
end

```
