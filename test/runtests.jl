using IndexShifts
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@testset "Unidimensional" begin
    @test @macroexpand(@shiftindex a[1]) == :(a[1 + 1])
    @test @macroexpand(@shiftindex a[i + j ÷ 2]) == :(a[(i + j ÷ 2) + 1])
    @test @macroexpand(@shiftindex begin 1 + a[1]; sin(a[x ^ 2]) end) == :(begin 1 + a[1 + 1]; sin(a[(x ^ 2) + 1]) end)
    @test @macroexpand(@shiftindex getindex(a, 1)) == :(getindex(a, 1 + 1))
    @test @macroexpand(@shiftindex x a[1]) == :(a[1 + x])
end

@testset "Multidimensional" begin
    @test @macroexpand(@shiftindex a[1, 1]) == :(a[1 + 1, 1 + 1])
    @test @macroexpand(@shiftindex a[i + j ÷ 2, i ^ 2]) == :(a[(i + j ÷ 2) + 1, (i ^ 2) + 1])
    @test @macroexpand(@shiftindex begin 1 + a[1, 2]; sin(a[x ^ 2, 1]) end) ==
        :(begin 1 + a[1 + 1, 2 + 1]; sin(a[(x ^ 2) + 1, 1 + 1]) end)
    @test @macroexpand(@shiftindex getindex(a, 1, 2)) == :(getindex(a, 1 + 1, 2 + 1))
    @test @macroexpand(@shiftindex x a[1, 2]) == :(a[1 + x, 2 + x])
end
