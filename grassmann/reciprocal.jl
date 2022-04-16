using Grassmann, SymPy
@basis S"+++" E e

#=
   geometric algebra scalar product: M1 * M2 = < M1 M2 >_0
=#
function dotscalar( x, y )
   grade(x * y, 0)
end

#=
   dot product of k-blade with (k+1)-blade: B1 . B2 = < B1 B2 >_1
=#
function dotvec( x, y )
   grade(x * y, 1)
end


a1, a2, a3, b1, b2, b3, c1, c2, c3 = symbols("a1, a2, a3, b1, b2, b3, c1, c2, c3", real=true) 
#@vars a1 b1 c1
#@vars a2 b2 c2
#@vars a3 b3 c3

x1 = a1 * e1 + b1 * e2 + c1 * e3
x2 = a2 * e1 + b2 * e2 + c2 * e3
x3 = a3 * e1 + b3 * e2 + c3 * e3

I = wedge(x1, x2, x3)
Iinv = I/(I * I)

y1 = dotvec(wedge(x2,x3), Iinv)
y2 = dotvec(wedge(x1,x3), -1 * Iinv)
y3 = dotvec(wedge(x1,x2), Iinv)

println( x1 )
println( x2 )
println( x3 )

#=
   dot product of k-blade with (k+1)-blade: B1 . B2 = < B1 B2 >_1
=#
function show( x, y, i, j )
   d = factor(expand(dotscalar( x, y )))
   println( "x$i . y$j = ", d )
end

println( "y1 = $y1" )
println( "y2 = $y2" )
println( "y3 = $y3" )

#x11 = dotscalar(x1, y1)
#println( "(simplify): x1.y1 = ", simplify(x11) )
#println( "(expand): x1.y1 = ", expand(x11) )
#println( "(factor(expand)): x1.y1 = ", factor(expand(x11)) )

show( x1, y1, 1, 1 )
show( x2, y2, 2, 2 )
show( x3, y3, 3, 3 )

show( x1, y2, 1, 2 )
show( x1, y3, 1, 3 )
show( x2, y1, 2, 1 )
show( x2, y3, 2, 3 )
show( x3, y1, 3, 1 )
show( x3, y2, 3, 2 )

