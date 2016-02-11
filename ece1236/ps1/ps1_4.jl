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

Rs = sqrt( omega * mu /(2 * sigma) ) ;

@printf( "R_\\txts = %0.4g\n", Rs ) ;
@printf( "\\eta = %0.4g\n", eta ) ;

dunits = [ "1 \\,\\si{cm}", "1 \\,\\si{mm}", "1 \\mu \\si{m}" ]
for useLog in [ false, true ]
   i=1
   for d in [ 1e-2, 1e-3, 1e-6 ]
      alpha = Rs/(d * eta) ;

      if ( useLog == false )
         @printf( "\\alpha(%s) &= %g \\si{m^{-1}} \\\\\n", dunits[i], alpha ) ;
      else
         @printf( "L(%s) &= %g \\si{dB}/m \\\\\n", dunits[i], 20 * alpha * log10( e ) ) ;
      end
      i = i + 1 ;
   end
end
