   # p2: Problem 2.  Code to confirm the zeros numerically, and to plot the absolute array factor.

   kd = 2 * pi * (1/2) ;

   theta = 0:0.01:pi ;
   thetaZeros = [0, pi/3, 2 * pi/3 ] ;

   expValues = exp( im * ( kd * cos( theta ) ) ) ;
#   expValuesZ = exp( im * ( kd * cos( thetaZeros ) ) ) ;

   af = abs((1 + expValues + expValues.^2 + expValues.^3)/4) ;
#   afz = (1 + expValuesZ + expValuesZ.^2 + expValuesZ.^3)/4 ;

   cosValues = abs( cos( kd * cos( theta )/2 ) + cos( 3 * kd * cos( theta )/2 ) )/2 ;
   cosValuesZ = (cos( kd * cos( thetaZeros )/2 ) + cos( 3 * kd * cos( thetaZeros )/2 ))/2 

# manual unit test: confirm the zeros:
#      disp( afz )
#      disp( cosValuesZ )

   using PyPlot ;

   fig = figure("p2Fig1",figsize=(10,10)) ; # Create a new figure
   ax = axes(polar="true") ; # Create a polar axis
   p = plot(theta, cosValues,linestyle="-",marker="None") ; # Basic line plot

   dtheta = 30 ;
   ax[:set_thetagrids]([0:dtheta:360-dtheta]) ; # Show grid lines from 0 to 360 in increments of dtheta
   ax[:set_theta_zero_location]("E") ; # Set 0 degrees to the top of the plot
   fig[:canvas][:draw]() ; # Update the figure

   savefig("plot.svg")
   savefig("plot.pdf")
   savefig("plot.png")

