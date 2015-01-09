#julia t0.jl 1 2

# docs coming in julia 0.4:
# http://stackoverflow.com/questions/19821247/how-to-make-user-defined-function-descriptions-docstrings-available-to-julia

# note that #=...=# can be used for a multiline comment.
#=
@doc """
   Sum two elements.
""" ->
=#
function mysumfunction(x,y)
   # a function.

   x + y
end

#?mysumfunction

y = Int64[] ;

for x in ARGS
   println( x )

   xi = int(x) 
   push!( y, xi ) 
end

z = mysumfunction(y...) ;

println( "z: ", z )
