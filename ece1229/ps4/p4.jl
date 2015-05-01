# Pkg.add("PyPlot")
# Pkg.add("Cubature")
using Cubature ;
using PyPlot ;

#
# for 20 log10( R ) = 40, -> R = 10^2, expand the array factor coefficients
# for a 5 element array.
#
function computeCoefficients()

   x0 = cosh( acosh( 100 )/4 ) ;
   x0sq = x0 * x0 ;
   x0q  = x0sq * x0sq ;

   den = 8 * x0q - 8 * x0sq + 1 ;

   alpha = x0q/den ;
   beta = (4 * x0q - 4 * x0sq)/den ;
   gamma = (3 * x0q - 4 * x0sq + 1) /den ;

   [alpha, beta, gamma]
end

# display the coefficients and the directivities, do the plots and save them to a file.
function p4()

   c = computeCoefficients() ;
   I = [ c[1]/2, c[2]/2, c[3], c[2]/2, c[1]/2 ]

   for k = 1:5
      @printf( "I_%d = %0.2f\n", k, I[k] ) ;
   end

   # omega[1] = theta, omega[2] = phi

   afX(omega) = c[1] * cos( 2 * pi * sin(omega[1]) * cos(omega[2]) ) +
                c[2] * cos( pi * sin(omega[1]) * cos(omega[2])) +
                c[3] ; 
   AFSquaredSinThetaX(omega) = afX(omega)^2 * sin(omega[1]) ;

   (Prad, e) = hcubature( AFSquaredSinThetaX, [0, 0], [pi, 2 * pi] ) ;
   dx = 4 * pi / Prad ;
   dxDb = 10 * log10( dx ) ;

   println( "D: x-axis: $dx, $dxDb dB ($e)" ) ;

   afZ(omega) = c[1] * cos( 2 * pi * cos(omega[1]) ) +
                c[2] * cos( pi * cos(omega[1]) ) +
                c[3] ; 
   AFSquaredSinThetaZ(omega) = afZ(omega)^2 * sin(omega[1]) ;

   (Prad, e) = hcubature( AFSquaredSinThetaZ, [0, 0], [pi, 2 * pi] ) ;

   dz = 4 * pi / Prad ;
   dzDb = 10 * log10( dz ) ;

   println( "D: z-axis: $dz, $dzDb dB ($e)" ) ;

   theta = 0:0.02:1 * pi ;
   afx = zeros( length(theta) ) ;
   afz = zeros( length(theta) ) ;

   i = 1 ;
   for t = theta
      afx[i] = ( afX( [t, 0] ) )^2 ;
      afz[i] = ( afZ( [t, 0] ) )^2 ;

      i = i + 1 ;
   end 

   f1 = figure("p4Fig1",figsize=(10,10)) ; # Create a new figure
   ax1 = axes( polar="true" ) ; # Create a polar axis
#   p1 = plot( theta, afx, linestyle="-", marker="None" ) ;
   p2 = plot( theta, afz, linestyle="-", marker="None" ) ;

   dtheta = 30 ;
   ax1[:set_thetagrids]([0:dtheta:360-dtheta]) ; # Show grid lines from 0 to 360 in increments of dtheta
   ax1[:set_theta_zero_location]("E") ; # Set 0 degrees to the top of the plot
   f1[:canvas][:draw]() ; # Update the figure

   #savefig("p4Fig1.svg")
   savefig("p4Fig1.pdf")
   savefig("p4Fig1pn.png")
end

function p4x( logthresh )

   c = computeCoefficients() ;
   I = [ c[1]/2, c[2]/2, c[3], c[2]/2, c[1]/2 ]

   # omega[1] = theta, omega[2] = phi
   theta = linrange( 0, 1 * pi, 500 ) ;
   st = pi * sin(theta) * cos( 0 ) ;

   af = (c[1] * cos( 2 * st ) +
         c[2] * cos( st ) +
         c[3]).^2 ; 

   uf = sinc( 2.5 * st ).^2 ;

   U = Array( Float64, length(theta), 2 ) ;
   U[:,1] = af ;
   U[:,2] = uf ;

   polarPlot( theta, U, "testmult"; logThreshDB = logthresh, normalize = true )
end
