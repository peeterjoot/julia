# difference between spherical volume and cubic volume for a few "radii"

v(r) = (4/3) * pi * r^3
# test: is 4/3 an integer or float in julia?:
#println( 4/3 )

os = v(0.8/2)
ns = v(1.3/2)

c(r) = (r*2)^3
oc = c(0.8/2)
nc = c(1.3/2)

println( os )
println( ns )
println( oc )
println( nc )
println( v(1/2) )
println( c(1/2) )

