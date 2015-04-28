# Pkg.add("PyPlot")
using PyPlot ;

# replot in log scale:
# 'Polar plot of radiation intensities for some electric z-axis oriented dipoles.'
function p2()

   alphas = [ 0.5, 1.0, 1.25, 2.0 ] ;
   theta = 0:0.02:1 * pi ;
   n = length(theta) ;
   m = length(alphas) ;
   U = zeros( n, m ) ;
   V = zeros( n, m ) ;

   maxU = -1 ;
   j = 1 ;
   for a = alphas
      kd = pi * a ;

      i = 1 ;
      for t = theta
         v = (cos( kd * cos( t ) ) - cos( kd ))/sin( t ) ;
         w = v^2 ;
         U[i, j] = w ;

         if ( w > maxU )
            maxU = w ;
         end

         i += 1 ;
      end 

      j += 1 ;
   end 

   U /= maxU ;
   for i = 1:n
      for j = 1:m
         v = log10( U[i, j] ) ;
         if ( v < -50/10 )
            v = 0 ;
         else
            v = v/5 + 1 ;
         end

         V[i, j] = v ;
      end
   end

   f1 = figure("p2Fig1",figsize=(10,10)) ; # Create a new figure
   ax1 = axes( polar="true" ) ; # Create a polar axis

   # linestyles: -, -., --, :
   pl1 = plot( theta, V[:,1], linestyle="-", marker="None" ) ;
   pl2 = plot( theta, V[:,2], linestyle="-", marker="None" ) ;
   pl3 = plot( theta, V[:,3], linestyle="-", marker="None" ) ;
   pl4 = plot( theta, V[:,4], linestyle="-", marker="None" ) ;

   dtheta = 30 ;
   ax1[:set_thetagrids]([0:dtheta:360-dtheta]) ; # Show grid lines from 0 to 360 in increments of dtheta
   ax1[:set_theta_zero_location]("E") ; # Set 0 degrees to the top of the plot

   ax1[:set_yticks]([0.2,0.4,0.6,0.8,1.0])
   ax1[:set_yticklabels](["-40dB","-30dB","-20dB","-10dB","0dB"])

   # http://www.scolvin.com/juliabyexample/
   PyPlot.legend(alphas, loc="lower right") ;

   f1[:canvas][:draw]() ; # Update the figure

   #savefig("ps3p2Fig1.svg")
   savefig("ps3p2Fig1.pdf")
   savefig("ps3p2Fig1pn.png")
end
