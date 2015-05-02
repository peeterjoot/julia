include("../ps4/polarPlot.jl") ;

function cheb( logthresh )

   theta = linrange( 0, 1 * pi, 500 ) ;

   #af = 40 cos^3(π (d/λ) cos θ) − 6.4 cos(π (d/λ) cos θ)
   alphas = [ 1/8, 1/4, 1/2 ] 
   lables = [ "\$ d/\\lambda = 1/8\$", "\$ d/\\lambda = 1/4\$", "\$ d/\\lambda = 1/4\$" ] ;

   ct = pi * cos( theta ) ;

   U = Array( Float64, length( theta ), 3 ) ;

   s1 = 6.4/40 ;
   for i = 1:3
      U[:,i] = ((1/(1 - s1)) * (cos( alphas[i] * ct ).^3 - s1 * cos( alphas[i] * ct ))).^2 ;
   end

   polarPlot( theta, U, "cheb"; logThreshDB = logthresh, legends = lables ) ;
end
