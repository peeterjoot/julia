## how to do this?
#
#julia> x = "alfjs aab"
#"alfjs aab"
#
#julia> x[end]
#'b'
#
#julia> length(x)
#9
#
#julia> x[end+1] = 'x'
#ERROR: `setindex!` has no method matching setindex!(::ASCIIString, ::Char, ::Int64)
#
#julia> x[end] = 'x'
#ERROR: `setindex!` has no method matching setindex!(::ASCIIString, ::Char, ::Int64)
#
#julia> x(end) = 'x'
#ERROR: syntax: unexpected end
#
#julia> x = 1:5
#1:5
#
#julia> x[1]
#1
#
#julia> x[end]
#5
#
#julia> x[end+1] = 3
#ERROR: setindex! not defined for UnitRange{Int64}
# in setindex! at abstractarray.jl:440 (repeats 2 times)
#
#julia> x = (1,3,3)
#(1,3,0)
#
#julia> x[end+1] = 3
#ERROR: `setindex!` has no method matching setindex!(::(Int64,Int64,Int64), ::Int64, ::Int64)
#
#julia> push!(x,3)
#ERROR: `push!` has no method matching push!(::(Int64,Int64,Int64), ::Int64)
#
#

x = Int64[] ;

push!(x, 3) ;
push!(x, 1) ;
push!(x, 4) ;

x

