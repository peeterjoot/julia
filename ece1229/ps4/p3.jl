function p3( logthresh )
   theta = linrange( 0, 1 * pi, 500 ) ;
   ct = pi * cos(theta) ;

   u = 5 * pi * cos( theta ) / 8 ;
   #U = cos( u ).^4 ;

   # plot power:
   U = cos( u ).^8 ;

   polarPlot( theta, U, "ps4p3" ; logThreshDB = logthresh ) ;
end
