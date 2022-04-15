# Pkg.add("PyPlot")
using PyPlot ;

include("otto.jl")

function p2( )

#Happy Birthday
#12345678911111
#         012345
   logThresh = -30 ;

# https://discourse.julialang.org/t/undefvarerror-linspace-not-defined/13269
#   theta = linrange( 0, 1 * pi, 500 ) ;
#   theta = LinRange( 0, 1 * pi, 500 ) ;
   theta = range( 0, stop=1 * pi, length=500 ) ;
   #n = length(theta) ;

   ct = pi * cos.(theta) ;
   U = 0.5 * abs.( cos.( ct /2 ) + cos.( 1.5 * ct) ) ;

   otto( theta, U, "otto" ; logThreshDB = logThresh, saveExt = "pdf" ) ;
end

p2()
