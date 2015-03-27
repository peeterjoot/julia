Pkg.add("Cubature")
Pkg.update()

using Cubature ;

h(x) = x[1]^2 * x[2] ;
g(x) = cos( pi * sin(x[1]) * cos(x[2]) ) ;
f(x) = cos( pi * sin(x[1]) * cos(x[2]) ) * sin(x[1]) ;

hcubature(h, [0,0], [1,2]) 
hcubature(g, [0,0], [pi/2,pi/2]) 
hcubature(f, [0,0], [pi/2,pi/2]) 

