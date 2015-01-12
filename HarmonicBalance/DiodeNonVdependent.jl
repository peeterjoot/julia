using SparseUtil ;

type NonlinearMatrices_T
   innerD
   outerD
   H
   A
end

#=
   DiodeNonVdependent: V independent parts of the diode current and Jacobian calculations.

FIXME: introduce type for input params (or more): p.nonlinear, p.D, p.Y, p.F, p.Finv
=#
function DiodeNonVdependent( p )

   nonlinear = p.nonlinear ;

   S = length( nonlinear ) ;
   dsz = size( p.D, 1 ) ;
   #traceit( "entry:  S = $S, dsz = $dsz" ) ;

   vSize = length( p.Y ) ;
   twoNplusOne = size( p.F, 1 ) ;
   nonlinearMatrices = NonlinearMatrices_T[] ;

   for i = 1:S
      #traceit( "$i" ) ;
      dio = nonlinear[i] ;

      innerD = spzerosT( vSize, twoNplusOne, 0 ) ;
      outerD = spzerosT( vSize, twoNplusOne, 0.0 ) ;

      vecInnerD = spzerosT( dsz, 1, 0 ) ;
      vecOuterD = p.D[ :, i ] ;

      # for Ennnn non-linear terms the selector of the vp/vn components differs from the scale of the non-linear contribution:
      if ( dio.vp )
         vecInnerD[ dio.vp ] = 1 ;
      end
      if ( dio.vn )
         vecInnerD[ dio.vn ] = -1 ;
      end

      for j = 1:twoNplusOne
         innerD[ 1 + (j-1) * dsz : j * dsz, j ] = vecInnerD ;
         outerD[ 1 + (j-1) * dsz : j * dsz, j ] = vecOuterD ;
      end

      A = dio.io * outerD * p.Finv ;

      H = p.F * innerD.' /dio.vt ;

      # don't really have to cache innerD,outerD but keep for debug for now.
      nl = NonlinearMatrices_T( innerD, outerD, H, A ) ;

      push!( nonlinearMatrices, nl ) ;
   end

   #traceit( 'exit' ) ;

   nonlinearMatrices ;
end
