# Pkg.add("PyPlot")
using PyPlot ;

# logThreshDB: 0, or negative multiple of -10 (or -5 if >= -25).
# normalize = true: don't assume the function is normalized to unity.
# savename: a string for the plot save name.

function polarPlot(theta, U, savename, logThreshDB = 0, normalize = false)

   if ( normalize )
      maxU = maximum( U ) ;
      U /= maxU ;
   end

   f1 = figure( "p2Fig1", figsize=(10,10) ) ; # Create a new figure
   ax1 = axes( polar="true" ) ; # Create a polar axis

   if ( logThreshDB == 0 )
      V = U ;
   else
      # convert to dB scale:
      #println( "$logThreshDB" ) ;
      V = clamp( 10 * log10( U ), logThreshDB, 0 )/(-logThreshDB) + 1 ;
   end

   # linestyles: -, -., --, :
   plot( theta, V, linestyle="-", marker="None" ) ;

   dtheta = 30 ;
   ax1[:set_thetagrids]([0:dtheta:360-dtheta]) ; # Show grid lines from 0 to 360 in increments of dtheta
   ax1[:set_theta_zero_location]("E") ; # Set 0 degrees to the top of the plot

   if ( logThreshDB < 0 )
      if ( logThreshDB >= -25 )
         # assume logThreshDB = -5 * logdelta ; logdelta integer
         logdelta = integer(logThreshDB/(-5)) ;

         # tick labels excluding origin
         yticksN = logThreshDB + 5 : 5 : 0 ;

      else
         # assume logThreshDB = -10 * logdelta ; logdelta integer
         logdelta = integer(logThreshDB/(-10)) ;

         # tick labels excluding origin
         yticksN = logThreshDB + 10 : 10 : 0 ;
      end

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
   #PyPlot.legend( alphas, loc="lower right" ) ;

   f1[:canvas][:draw]() ; # Update the figure

   if ( logThreshDB < 0 )
      figDesc = "LogScale$(-logThreshDB)" ;
   else
      figDesc = "Linear" ;
   end

   #savefig("ps4p2$(figDesc)Fig1.svg")
   savefig("ps4p2$(figDesc)Fig1.pdf")
   #savefig("ps4p2$(figDesc)Fig1pn.png")
end
