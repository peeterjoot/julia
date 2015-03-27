#
# for 20 log10( R ) = 40, -> R = 10^2, expand the array factor coefficients
# for a 5 element array.
#
function computeCoefficients()

   x0 = cosh( acosh( 100 )/4 ) ;
   x0sq = x0 * x0 ;
   x0q  = x0sq * x0sq ;

   den = 8 * x0q - 8 * x0sq + 1 ;

   alpha = x0q/den ;
   beta = (4 * x0q - 4 * x0sq)/den ;
   gamma = (3 * x0q - 4 * x0sq + 1) /den ;

   I = [ alpha/2, beta/2, gamma, beta/2, alpha/2 ]
end

function displayCoefficients()

   I = computeCoefficients() ;

   for k = 1:5
      @printf( "I_%d = %0.2f\n", k, I[k] ) ;
   end

end
