function [II, JI] = DiodeCurrentAndJacobian( in, V )
   % DiodeCurrentAndJacobian: Calculate the non-linear current contributions of the diode
   % and its associated Jacobian.

   S = length( in.nonlinearMatrices ) ;
   %traceit( sprintf( 'entry.  S = %d', S ) ) ;

   vSize = size( in.Y, 1 ) ;
   twoNplusOne = size( in.F, 1 ) ;

   II = zeros( vSize, 1 ) ;
   JI = zeros( vSize, vSize ) ;

   for i = 1:S
      H = in.nonlinearMatrices{ i }.H ;

      expType = ( strcmp( in.nonlinear{ i }.type, 'exp' ) ) ;
      if ( ~expType )
         exponentValue = in.nonlinear{ i }.exponent ;
      end

      ee = zeros( twoNplusOne, 1 ) ;
      eeprime = zeros( twoNplusOne, 1 ) ;
      he = zeros( twoNplusOne, vSize ) ;

      for j = 1:twoNplusOne
         ht = H( j, : ) ;

         x = ht * V ;

         if ( expType )
            g      = exp( x ) ;
            gPrime = g ;
         else
            g      = ( x )^( exponentValue ) ;
            gPrime = exponentValue * ( x )^( exponentValue - 1 ) ;
         end

         ee( j ) = g ;
         he( j, : ) = ht * gPrime ;
      end

      II = II + in.nonlinearMatrices{ i }.A * ee ;
      JI = JI + in.nonlinearMatrices{ i }.A * he ;
   end

   %traceit( 'exit' ) ;
end
