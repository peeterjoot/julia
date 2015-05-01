# Pkg.add("PyPlot")
using PyPlot ;

#
# logThreshDB: one of:
#  0
#  negative multiple of -10 (when <= -30)
#  negative multiple of -5 (when >= -25).
#
# normalize = true: don't assume the function is normalized to unity.
#
# savename: a string for the plot save name.
#
# X: array(length(theta), n)
#
# legends: of size(X,2) != 1, this should be an array of that size, with a legend value for each plot.
#
function polarPlot( theta, X, savename ; logThreshDB = 0, normalize = false, saveExt = "pdf", legends = [] )

   if ( normalize )
      maxU = maximum( X ) ;
      X /= maxU ;
   end

   f1 = figure( "fig", figsize=(10,10) ) ; # Create a new figure
   ax1 = axes( polar="true" ) ; # Create a polar axis

   n = size( X, 2 ) ;

   if ( logThreshDB == 0 )
      V = X ;
   else
      # convert to dB scale:
      #println( "$logThreshDB" ) ;
      V = Array( Float64, size(X) ) ;

      for i = 1:n
         V[:,i] = clamp( 10 * log10( X[:,i] ), logThreshDB, 0 )/(-logThreshDB) + 1 ;
      end
   end

   for i = 1:n
      # linestyles: -, -., --, :
      plot( theta, V[:,i], linestyle="-", marker="None" ) ;
   end

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

   if ( length(legends) != 0 )
      # http://www.scolvin.com/juliabyexample/
      PyPlot.legend( legends, loc="lower right" ) ;
   end

   f1[:canvas][:draw]() ; # Update the figure

   if ( logThreshDB < 0 )
      figDesc = "LogScale$(-logThreshDB)" ;
   else
      figDesc = "Linear" ;
   end

   savefig("$(savename)$(figDesc)Fig1.$saveExt")
end
