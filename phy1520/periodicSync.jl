# scales are distorted in this plot.  wanted two lines in this figure too.

#Pkg.add("PyPlot")
using PyPlot
r = 50 ;
theta = collect(-r:0.01:r) ;
n = 30 ;
f = sin((n + 1/2)* theta) ./ sin(theta) ;
plot(theta, f, linewidth=2.0, linestyle="--")
