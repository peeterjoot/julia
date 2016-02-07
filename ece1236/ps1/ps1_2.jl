# ps 1, (2).

c = 3e9 ;
e_r = 2.5 ;
vphi = c/sqrt(e_r) ;
C = 200e-12 ;
R = 2 ;
L = 1/(vphi^2 * C) ;
G = 0 ;

println( "vphi = $vphi" ) ;
println( "L = $L" ) ;

# f in GHz (1e9)
function Z(f, r)
   jomega = 2 * pi * f * im * 1e9 ;
   sqrt((r + jomega * L)/(G + jomega * C))
end

function gamma(f, r)
   jomega = 2 * pi * f * im * 1e9 ;
   sqrt((r + jomega * L)*(G + jomega * C))
end

function printV(f, z, l)

   zabs = abs(z) ; 
   zangle = angle(z) ;
   zangledegrees = zangle * 180 / pi ;

   #println("$z");
   @printf( "%s(f = %0.4g \\si{GHz}) &= %0.4g \\phase{ \\ang{%0.4g} } \\\\\n", l, f, zabs, zangledegrees ) ;
end

#function printG(f, g)
#
#   println( "$f: $g" ) ;
##   @printf( "\\gamma(f = %0.4g \\si{GHz}) &= %0.4g + %0.4g j \\\\\n", f, real(g), imag(g) ) ;
#end

function printA(f, g)

   @printf( "\\alpha(f = %0.4g \\si{GHz}) &= %0.4g \\\\\n", f, real(g) ) ;
end

function printE(f, g)

   lambda = vphi / (f * 1e9) ;
   @printf( "f = %0.4g: e^{-\\lambda * \\alpha} = %0.4g \\\\\n", f, exp(-lambda * real(g)) ) ;
end



printV( 1, Z(1, 0), "Z_0" ) ;
printV( 1, Z(1, R), "Z_0" ) ;
printV( 2, Z(2, R), "Z_0" ) ;
printV( 3, Z(3, R), "Z_0" ) ;
printV( 10, Z(10, R), "Z_0" ) ;

printV( 1, gamma(1, 0)/1.0, "\\gamma/f" ) ;
printV( 1, gamma(1, R)/1.0, "\\gamma/f" ) ;
printV( 2, gamma(2, R)/2.0, "\\gamma/f" ) ;
printV( 3, gamma(3, R)/3.0, "\\gamma/f" ) ;
printV( 10, gamma(10, R)/10.0, "\\gamma/f" ) ;

printA( 1, gamma(1, 0) ) ;
printA( 1, gamma(1, R) ) ;
printA( 2, gamma(2, R) ) ;
printA( 3, gamma(3, R) ) ;
printA( 10, gamma(10, R) ) ;

printE( 1, gamma(1, R) ) ;
printE( 2, gamma(2, R) ) ;
printE( 3, gamma(3, R) ) ;
printE( 10, gamma(10, R) ) ;
