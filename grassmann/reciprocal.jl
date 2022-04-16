using Grassmann, SymPy
@basis S"+++" E e

#=
   geometric algebra scalar product: M1 * M2 = < M1 M2 >_0
=#
function scalarproduct( x, y )
   grade(x * y, 0)
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

y1 =  grade(wedge(x2,x3) * Iinv, 1)
y2 = -grade(wedge(x1,x3) * Iinv, 1)
y3 =  grade(wedge(x1,x2) * Iinv, 1)

println( x1 )
println( x2 )
println( x3 )

println( y1 )
println( y2 )
println( y3 )

print( scalarproduct( x1, y1 ) )
print( scalarproduct( x2, y2 ) )
print( scalarproduct( x3, y3 ) )

print( scalarproduct( x1, y2 ) )
print( scalarproduct( x1, y3 ) )

print( scalarproduct( x2, y1 ) )
print( scalarproduct( x2, y3 ) )

print( scalarproduct( x3, y1 ) )
print( scalarproduct( x3, y2 ) )

