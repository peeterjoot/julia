#using Pkg;
#Pkg.add("Grassmann")

# This requires Grassmann 0.8.  Enter this in the repl to get it:
# ]
# add Grassmann#master

using Grassmann
@basis S"+++"

b1 = v12 + v23
m1 = b1 * v2
m2 = 1 + v1 + v123 + v23
m3 = m2 * v2

println( "m1 = ($b1) * $v2 = ", m1 )
for i = 0:3
   println( grade(m1, i) )
end

println( "m2 = $m2" )
for i = 0:3
   println( grade(m2, i) )
end

println( "m3 = ($m2) * $v2 = $m3" )
for i = 0:3
   println( grade(m3, i) )
end
