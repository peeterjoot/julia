
function mycrappypolar()
   crange = 0:0.05:2 *pi ;
   x = cos( crange ) ;
   y = sin( crange ) ;

   upper = 2 ;
   delta = 2/5 ;
   for i = delta:delta:upper ;
      plot( i * x, i * y ) ;
   end

   lrange = 0:0.05:upper ;
   for i = 0:pi/6:2 * pi - pi/6
      c = cos( i ) ;
      s = sin( i ) ;

      plot( c * lrange, s * lrange ) ;
   end

   range = 0:0.1:pi ;
   r = cos( range ).*2 ;
   xr = cos( range ) ;
   yr = sin( range ) ;

   plot( r .* xr, r .* yr ) ;
end
