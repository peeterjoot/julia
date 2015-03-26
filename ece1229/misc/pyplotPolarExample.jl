using PyPlot ;
theta = [0:2pi/100:2pi] ;
r = cos( theta ).^2 ;
#width = 2pi/length(theta) ; # Desired width of each bar in the bar plot

##########################
##  Windrose Line Plot  ##
##########################
fig = figure("pyplot_windrose_lineplot",figsize=(10,10)) ; # Create a new figure
ax = axes(polar="true") ; # Create a polar axis
#title("Wind Rose - Line") ;
p = plot(theta,r,linestyle="-",marker="None") ; # Basic line plot

dtheta = 30 ;
ax[:set_thetagrids]([0:dtheta:360-dtheta]) ; # Show grid lines from 0 to 360 in increments of dtheta
ax[:set_theta_zero_location]("E") ; # Set 0 degrees to the top of the plot
#ax[:set_theta_direction](-1) ; # Switch to clockwise 
fig[:canvas][:draw]() ; # Update the figure
