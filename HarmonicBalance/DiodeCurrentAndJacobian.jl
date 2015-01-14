#=
   DiodeCurrentAndJacobian: Calculate the non-linear current contributions of the diode
   and its associated Jacobian.

inputs:
   in[ :nonlinearMatrices ]
   in[ :Y ]
   in[ :F ]
   in[ :nonlinear ]
=#
function DiodeCurrentAndJacobian( in, V )

   S = length( in[ :nonlinearMatrices ] ) ;
   #traceit( "entry.  S = $S" ) ;

   vSize = size( in[ :Y ], 1 ) ;
   twoNplusOne = size( in[ :F ], 1 ) ;

   II = zeros( vSize, 1 ) ;
   JI = zeros( vSize, vSize ) ;

   for i in 1:S
      H = in[ :nonlinearMatrices ][ i ].H ;

      powerType = ( in[ :nonlinear ][ i ].type == :POWER ) ;
      if ( powerType )
         exponentValue = in[ :nonlinear ][ i ].exponent ;
      end

      ee = zeros( twoNplusOne, 1 ) ;
      eeprime = zeros( twoNplusOne, 1 ) ;
      he = zeros( twoNplusOne, vSize ) ;

      for j in 1:twoNplusOne
         ht = H[ j, : ] ;

         x = ht * V ;

         # FIXME: a little confusing to have both a power type (with an exponent variable)
         # and an exponent type representing e^x.
         if ( powerType )
            g      = ( x )^( exponentValue ) ;
            gPrime = exponentValue * ( x )^( exponentValue - 1 ) ;
         else
            g      = exp( x ) ;
            gPrime = g ;
         end

         ee[ j ] = g ;
         he[ j, : ] = ht * gPrime ;
      end

      II = II + in[ :nonlinearMatrices ][ i ].A * ee ;
      JI = JI + in[ :nonlinearMatrices ][ i ].A * he ;
   end

   #traceit( 'exit' ) ;

   [ II, JI ] ;
end
