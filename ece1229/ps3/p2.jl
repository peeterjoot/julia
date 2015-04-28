# Pkg.add("PyPlot")
using PyPlot ;

# Polar plot of radiation intensities for some electric z-axis oriented dipoles.
function p2()

   alphas = [ 0.5, 1.0, 1.25, 2.0 ] ;
   theta = 0:0.02:1 * pi ;
   U = zeros( length(theta), 4 ) ;

   j = 1 ;
   for a = alphas
      kd = pi * a ;

      i = 1 ;
      for t = theta
         v = (cos( kd * cos( t ) ) - cos( kd ))/sin( t ) ;

         U[i, j] = v^2 ;

         i = i + 1 ;
      end 

      j = j + 1 ;
   end 

   f1 = figure("p2Fig1",figsize=(10,10)) ; # Create a new figure
   ax1 = axes( polar="true" ) ; # Create a polar axis
   pl1 = plot( theta, U[:,1], linestyle="-", marker="None" ) ;
   pl2 = plot( theta, U[:,2], linestyle="-.", marker="None" ) ;
   pl3 = plot( theta, U[:,3], linestyle="--", marker="None" ) ;
   pl4 = plot( theta, U[:,4], linestyle=":", marker="None" ) ;

   dtheta = 30 ;
   ax1[:set_thetagrids]([0:dtheta:360-dtheta]) ; # Show grid lines from 0 to 360 in increments of dtheta
   ax1[:set_theta_zero_location]("E") ; # Set 0 degrees to the top of the plot
   f1[:canvas][:draw]() ; # Update the figure

   #savefig("p2Fig1.svg")
#   savefig("p2Fig1.pdf")
#   savefig("p2Fig1pn.png")
end
