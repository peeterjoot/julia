# ps 1, (4).

c = 3e8 ;
G = 0 ;
Ghz = 1e9 ;
dOverw = 0.1 ;
sigma = 3.538e7 ;
mu = pi * 4e-7 ;
epsilon = 8.8e-12 ;
eta = sqrt( mu/epsilon ) ;
f = 30 * Ghz ;
C = epsilon/dOverw ;
L = mu * dOverw ;
omega = 2 * pi * f ;

# part f)  Assuming R' = 0
Z = sqrt(L/C) ;
println( "Z_0 = $Z" ) ;

# good conductor?
omegaEpsilon = omega * epsilon ;

println( "Good conductor if: $sigma \\gg $omegaEpsilon" ) ;

# part g)
function r(d)
   dOverw * sqrt( pi * f * mu/sigma )/ d ;
end

function gamma(d)
   R = r(d) ;

   jomega = omega * im ;

   sqrt( (R + jomega * L) * ( G + jomega * C) ) ;
end

for d in [1e-2, 1e-3, 1e-6]
   g = gamma( d ) ;
   alpha = real( g ) ;
   z = r(d)/g ;

   @printf( "d = %g ; \\alpha(d) = %g ; Z_0(d) = %g + %g j\n", d, alpha, real(z), imag(z) ) ;
end
