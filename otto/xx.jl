# Pkg.add("PyPlot")
using PyPlot ;

function p2( )

#Happy Birthday
#12345678911111
#         012345
   logThresh = -30 ;

   theta = linrange( 0, 1 * pi, 500 ) ;
   n = length(theta) ;

   ct = pi * cos(theta) ;
   U = 0.5 * abs( cos( ct /2 ) + cos( 1.5 * ct) ) ;

   otto( theta, U, "otto" ; logThreshDB = logThresh, saveExt = "pdf" ) ;
end
