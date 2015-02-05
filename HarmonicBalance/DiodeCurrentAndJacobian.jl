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

   nonlinearMatrices   = in[ :nonlinearMatrices ] ;
   Y                   = in[ :Y ] ;
   F                   = in[ :F ] ;
   nonlinear           = in[ :nonlinear ] ;

   S = length( nonlinearMatrices ) ;
   #traceit( "entry.  S = $S" ) ;

   vSize = size( Y, 1 ) ;
   twoNplusOne = size( F, 1 ) ;

   II = zeros( Complex{Float64}, vSize, 1 ) ;
   JI = zeros( Complex{Float64}, vSize, vSize ) ;

   for i in 1:S
      H = nonlinearMatrices[ i ].H ;

      powerType = ( nonlinear[ i ].typeDesc == :POWER ) ;
      if ( powerType )
         exponentValue = nonlinear[ i ].exponent ;
      end

      # FIXME: Both of these doesn't actually have to be zero initialized.  Could just allocate.  How?
      ee = zeros( Complex{Float64}, twoNplusOne, 1 ) ;
      he = zeros( Complex{Float64}, twoNplusOne, vSize ) ;

      for j in 1:twoNplusOne
         ht = H[ j, : ] ;

         x = ht * V ;
#println( "x = ", x ) ;
         x = x[1,1] ; 
#println( typeof(x) ) ;

         # FIXME: a little confusing to have both a power type (with an exponent variable)
         # and an exponent type representing e^x.
         if ( powerType )
            g      = ( x )^( exponentValue ) ;
            gPrime = exponentValue * ( x )^( exponentValue - 1 ) ;
         else
            g      = exp( x ) ;
            gPrime = g ;
         end

         #println( x ) ;
         #println( typeof(x) ) ;
         #println( typeof(ee) ) ;
         #println( typeof(ee[j,1]) ) ;
         #println( typeof(g) ) ;
         ee[ j, 1 ] = g ;
  
         # Julia porting issue 1:
         # 
         # order appears to matter in Julia.  Changed [1 x N] * [1 x 1] => [1 x 1] * [1 x N].
         # can't seem to repro this with standalone code?
         # 
         #println( size(he) ) ;
         #println( typeof(j) ) ;
         #println( j ) ;
         #println( size(ht) ) ;
         #println( size(ht * gPrime) ) ;

         # Julia porting issue 2:
         # 
         # got inexact setindex error.  These showed that the issue was an attempt to assign
         # complex-float to float array.  Fixed with complex zeros init above.
         #println( typeof(ht * gPrime) ) ;
         #println( typeof(he[ j, : ])  ) ;
         # 
         he[ j, : ] = ht * gPrime ;
      end

      II = II + nonlinearMatrices[ i ].A * ee ;
      JI = JI + nonlinearMatrices[ i ].A * he ;
   end

   #traceit( 'exit' ) ;

   ( II, JI ) ;
end
