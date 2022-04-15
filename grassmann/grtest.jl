#using Pkg;
#Pkg.add("Grassmann")

# This requires Grassmann 0.8.  Enter this in the repl to get it:
# ]
# add Grassmann#master

using Grassmann
@basis S"+++" E e

b1 = e12 + e23
m1 = b1 * e2
m2 = 1 + e1 + e123 + e23
m3 = m2 * e2

println( "m1 = ($b1) * $e2 = ", m1 )
for i = 0:3
   println( grade(m1, i) )
end

println( "m2 = $m2" )
for i = 0:3
   println( grade(m2, i) )
end

println( "m3 = ($m2) * $e2 = $m3" )
for i = 0:3
   println( grade(m3, i) )
end

m4 = 1 + 2 * e1 + 3 * e2 + 4 * e3 + 5 * e12 + 6 * e13 + 7 * e23 + 8 * e123
println( m4 )
dump( m4 )

# doesn't work.  only eij i < j available as symbols:
#println( 5 * e21 + 6 * e31 + 7 * e32 )
