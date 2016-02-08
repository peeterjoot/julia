# ps 1, (2).

c = 3e8 ;
e_r = 2.5 ;
vphi = c/sqrt(e_r) ;
C = 200e-12 ;
R = 2 ;
L = 1/(vphi^2 * C) ;
G = 0 ;

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

function printG(f, r)
   g = gamma(f, r) ;
   omega = 2e9 * pi * f ; 
   #println( "$f: $g" ) ;
   #@printf( "\\gamma(f = %0.4g \\si{GHz}) &= %0.4g + \\omega %0.4g j \\\\\n", f, real(g), imag(g)/omega  ) ;
   @printf( "\\gamma &= %0.4g + \\omega %0.4g j \\\\\n", real(g), imag(g)/omega  ) ;
end

function printA(f, g)

   @printf( "\\alpha(f = %0.4g \\si{GHz}) &= %0.4g \\\\\n", f, real(g) ) ;
end

function printE(f, g)

   lambda = vphi / (f * 1e9) ;
   @printf( "f = %0.4g: e^{-\\lambda * \\alpha} = %0.4g \\\\\n", f, exp(-lambda * real(g)) ) ;
end

function printAB(f)
   z = Z(f, 0) ;
   alpha = (R/z + G * z)/2 ;
   omega = 2 * pi * f * 1e9 ;
   beta = omega * sqrt( L * C ) ;

   #@printf( "\\alpha = %0.4g + %0.4g j\n", real(alpha), imag(alpha) ) ;
   #@printf( "\\beta = %0.4g\n", beta ) ;
   @printf( "\\gamma &= %0.4g + \\omega %0.4g j \\\\\n", real(alpha), beta/omega ) ;
end

#println( "vphi = $vphi" ) ;
#println( "L = $L" ) ;

#printV( 1, Z(1, 0), "Z_0" ) ;
for i in [1,2,3,10]
   printV( i, Z(i, R), "Z_0" ) ;
end

printV( 1, gamma(1, 0)/1.0, "\\gamma/f" ) ;
for i in [1,2,3,10]
   printV( i, gamma(i, R)/i, "\\gamma/f" ) ;
end

printA( 1, gamma(1, 0) ) ;
for i in [1,2,3,10]
   printA( i, gamma(i, R) ) ;
end

for i in [1,2,3,10]
   printE( i, gamma(i, R) ) ;
end

for i in [1,2,3,10]
   printG( i, R ) ;
end

for i in [1,2,3,10]
   printAB( i ) ;
end
