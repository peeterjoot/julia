# scales are distorted in this plot.  wanted two lines in this figure too.

#Pkg.add("PyPlot")
using PyPlot
theta = collect(-pi/4:0.1:0) ;
x = 10 * cos(theta) ;
y = 10 * sin(theta) ;
plot(x, y, color="red", linewidth=2.0, linestyle="--")
