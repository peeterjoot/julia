# Pkg.add("PyPlot")
using PyPlot ;

function p3()

   alphas = [ 0.25, 0.325, 0.595, 1.055 ] ;
   phi = linrange( 0, 2 * pi, 300 ) ;
   n = length(phi) ;
   m = length(alphas) ;
   U = zeros( n, m ) ;

   j = 1 ;
   for a = alphas
      kd = 2 * pi * sqrt(2) * a ;

      U[:,j] = 2 * abs( cos( kd * cos(phi - pi/4) ) - cos ( kd * cos(phi + pi/4) )) ;
      j += 1 ;
   end

   maxU = maximum( U ) ;
      
   U /= maxU ;

   # convert to dB scale:
   logThresh = -30 ; # dB
   V = clamp( 10 * log10( U ), logThresh, 0 )/(-logThresh) + 1 ;

   f1 = figure("p3Fig1",figsize=(10,10)) ; # Create a new figure
   #ax1 = axes( [0.1, 0.1, 0.8, 0.8], polar="true" ) ; # Create a polar axis
   ax1 = axes( polar="true" ) ; # Create a polar axis

   logscale = false ;

   if ( ~logscale )
      V = U ;
   end

   # linestyles: -, -., --, :
   pl1 = plot( phi, V[:,1], linestyle="-", marker="None" ) ;
   pl2 = plot( phi, V[:,2], linestyle="-", marker="None" ) ;
   pl3 = plot( phi, V[:,3], linestyle="-", marker="None" ) ;
   pl4 = plot( phi, V[:,4], linestyle="-", marker="None" ) ;

   dtheta = 30 ;
   ax1[:set_thetagrids]([0:dtheta:360-dtheta]) ; # Show grid lines from 0 to 360 in increments of dtheta
   ax1[:set_theta_zero_location]("E") ; # Set 0 degrees to the top of the plot

   if ( logscale )
      # assume logThresh = -10 * logdelta ; logdelta integer
      logdelta = integer(logThresh/(-10)) ;

      # tick labels excluding origin
      yticksN = logThresh + 10 : 10 : 0 ;

      # tick positions in [0:1] interval:
      yrange = linrange( 1/logdelta, 1, logdelta ) ;

      yticks = Array( String, length( yrange ) ) ;
      for i = 1:logdelta
         yticks[i] = string( yticksN[i], "dB" ) ;
      end

      ax1[:set_yticks]( linrange( 1/logdelta, 1, logdelta ) ) ;
      ax1[:set_yticklabels]( yticks ) ;
   end

   # http://www.scolvin.com/juliabyexample/
   PyPlot.legend( alphas, loc="lower right" ) ;

   f1[:canvas][:draw]() ; # Update the figure

   #savefig("ps3p3Fig1.svg")
#   savefig("ps3p3Fig1.pdf")
#   savefig("ps3p3Fig1pn.png")
end
