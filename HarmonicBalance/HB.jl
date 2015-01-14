module HB
   using pd ;

   export HBSolve ;

#   include("FourierMatrixComplex.jl") ;
#   include("DiodeNonVdependent.jl") ;
#   include("DiodeCurrentAndJacobian.jl") ;
#   include("HarmonicBalance.jl") ;
   include("HBSolve.jl") ;

#function HBSolve( N, p )
#   # Dict of Symbol,Any: (could replace Any with Union(Int,Bool,Float64))
#   defp = [ :tolF =>             1e-6,
#            :edV =>              1e-3,
#            :JcondTol =>         1e-23,
#            :iterations =>       50,
#            :subiterations =>    50,
#            :minStep =>          0.0001,
#            :dlambda =>          0.01,
#            :dispfrequency =>    1,
#            :maxStepMultiples => 50 ] ;
#
#   for k in keys( defp )
#      if ( !haskey( p, k ) )
#         p[ k ] = defp[ k ] ;
#      end
#   end
#
#   p
#end

end

