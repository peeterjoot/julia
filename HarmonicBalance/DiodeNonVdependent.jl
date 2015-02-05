using SparseUtil ;

type NonlinearMatrices_T
   innerD
   outerD
   H
   A
end

#=
   DiodeNonVdependent: V independent parts of the diode current and Jacobian calculations.

=#
function DiodeNonVdependent( p )

   nonlinear = p[ :nonlinear ] ;
   D = p[ :D ] ;
   F = p[ :F ] ;
   Finv = p[ :Finv ] ;

   S = length( nonlinear ) ;
   dsz = size( D, 1 ) ;
   traceit( "entry:  S = $S, dsz = $dsz" ) ;

   szY = size( p[ :Y ] ) ;
   vSize = szY[1] ;
   twoNplusOne = size( F, 1 ) ;
   nonlinearMatrices = NonlinearMatrices_T[] ;

   for i in 1:S
      #traceit( "$i" ) ;
      dio = nonlinear[i] ;

      innerD = spzerosT( vSize, twoNplusOne, 0 ) ;
      outerD = spzerosT( vSize, twoNplusOne, 0.0 ) ;
traceit( "vSize = $vSize, twoNplusOne = $twoNplusOne" ) ;

      vecInnerD = spzerosT( dsz, 1, 0 ) ;
      vecOuterD = D[ :, i ] ;

      # for Ennnn non-linear terms the selector of the vp/vn components differs from the scale of the non-linear contribution:
      if ( dio.vp != 0 )
         vecInnerD[ dio.vp ] = 1 ;
      end
      if ( dio.vn != 0 )
         vecInnerD[ dio.vn ] = -1 ;
      end

      for j in 1:twoNplusOne
         innerD[ 1 + (j-1) * dsz : j * dsz, j ] = vecInnerD ;
         outerD[ 1 + (j-1) * dsz : j * dsz, j ] = vecOuterD ;
      end

      A = dio.magnitude * outerD * Finv ;

#println( "size(vecInnerD) = ", size(vecInnerD) ) ;
#println( "size(vecOuterD) = ", size(vecOuterD) ) ;
#println( "size(F) = ", size(F) ) ;
#println( "size(innerD') = ", size(innerD') ) ;
      H = F * innerD.' /dio.vt ;

      # don't really have to cache innerD,outerD but keep for debug for now.
      nl = NonlinearMatrices_T( innerD, outerD, H, A ) ;

      push!( nonlinearMatrices, nl ) ;
   end

   #traceit( 'exit' ) ;

   nonlinearMatrices ;
end
