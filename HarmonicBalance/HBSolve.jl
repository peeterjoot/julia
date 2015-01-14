using Netlist ;
using CPUTime ;

#=
  Uses the Harmonic Balance Method to solve the
  steady state condtion of the circuit described in p[ :fileName ]

  Harmonic frequencies are limited to N.

  It returns the vector containing the unknowns of the circuit, v, ordered as
  described in HarmonicBalance.jl and the cpu time required to solve the
  circuit using Newton's Method.
=#
function HBSolve( N, p )
   # Dict of Symbol,Any: (could replace Any with Union(Int,Bool,Float64))
   defp = [ :tolF =>             1e-6,
            :edV =>              1e-3,
            :JcondTol =>         1e-23,
            :iterations =>       50,
            :subiterations =>    50,
            :minStep =>          0.0001,
            :dlambda =>          0.01,
            :dispfrequency =>    1,
            :maxStepMultiples => 50 ] ;

   for k in keys( defp )
      if ( !haskey( p, k ) )
         p[ k ] = defp[ k ] ;
      end
   end

   r = NodalAnalysis( p[ :fileName ] ) ;

   # Harmonic Balance Parameters
   # Only intend on using one frequency for all AC sources

   a = r[ :angularVelocities ] ;
   omega = minimum( a[ a .> 0 ] ) ;

   r = HarmonicBalance( r, N, omega ) ;

   G = r[ :G ] ;
   Y = r[ :Y ] ;
   I = r[ :I ] ;
   F = r[ :F ] ;
   R = length( G ) ;

   # Newton's Method Parameters
   if ( haskey( p, :linearInit ) && p[ :linearInit ] && (rcond( Y ) > 1e-6) )
      # suggested by wikipedia HB article: use the linear solution
      # as a seed, but this doesn't work out well for some circuits ( i.e. halfWaveRectifier )
      V0 = Y\I ;
   elseif ( haskey( p, :complexRandInit ) && p[ :complexRandInit ] )
      V0 = rand( R * ( 2 * N + 1 ), 1 ) + im * rand( R * ( 2 * N + 1 ), 1 ) ;
   elseif ( haskey( p, :randInit ) && p[ :randInit ] )
      V0 = rand( R * ( 2 * N + 1 ), 1 ) ;
   else
      V0 = zeros( R * ( 2 * N + 1 ), 1 ) ;
   end

   totalIterations = 0 ;

   # Source Stepping
   lambda = 0 ;
   plambda = 0 ;
   dlambda = p[ :dlambda ] ;
   converged = false ;
   ecputime = CPUtime_us() ;
println( p[ :iterations ] ) ;

#=
   for i in 1:p[ :iterations ]
      V = V0 ;

      [Inl, JI] = DiodeCurrentAndJacobian( r, V ) ;

      # Function to minimize:
      f = Y * V - Inl - lambda * I ;

      J = Y - JI ;
      jcond = rcond( J ) ;

      # half wave rectifier (and perhaps other circuits) can't converge when lambda == 0.  have to start off bigger.
      if ( 0 == lambda )
         #while ( ( jcond < p[ :JcondTol ] ) || isnan( jcond ) )

#         # First fall back to zeros for the initial vector.  Could alternately step that initial vector selection.
#         if ( isnan( jcond ) )
#            V0 = zeros( R * ( 2 * N + 1 ), 1 ) ;
#            V = V0 ;
#            f = Y * V - Inl - dlambda * I ;
#
#            J = Y - JI ;
#            jcond = rcond( J ) ;
#         end

         while ( isnan( jcond ) )
            println( "lambda: $dlambda, cond = $jcond" ) ;

            dlambda = dlambda + p[ :dlambda ] ;

            f = Y * V - Inl - dlambda * I ;

            J = Y - JI ;
            jcond = rcond( J ) ;

            if ( dlambda > 1 )
               throw( "could not find an initital source load step" ) ;
            end
         end

         lambda = dlambda ;
         plambda = dlambda ;
      end

      if ( 0 == ( i % p[ :dispfrequency ] ) )
         println( "iteration $i: lambda: $lambda, |V0| = ", norm( V0 ), ", cond = $jcond" ) ;
      end

      stepConverged = false ;

      for k in 1:p[ :subiterations ]

         # Newton Iteration Update
         dV = J\-f ;
         V = V + dV ;

         [Inl, JI] = DiodeCurrentAndJacobian( r, V ) ;

         # Function to minimize:
         f = Y * V - Inl - lambda * I ;

         # Construct Jacobian
         J = Y - JI ;
         jcond = rcond( J ) ;

         if ( ( jcond < p[ :JcondTol ] ) || isnan( jcond ) )
            stepConverged = false ;
            break
         end

         if ( norm( f ) < p[ :tolF ] ) || ( norm( dV ) < p[ :edV ] )
            stepConverged = true ;
            break ;
         end
      end

      if ( stepConverged )
         # println( "solution converged" )
         V0 = V ;

         trialLambda = 2 * dlambda ;

         # don't allow the step size to go too many multiples bigger than the default step size if it has been decreased.
         if ( trialLambda < ( p[ :maxStepMultiples ] * p[ :dlambda ] ) )
            dlambda = trialLambda ;
         else
            dlambda = p[ :dlambda ] ;
         end

         plambda = lambda ;
         lambda = lambda + dlambda ;
      else
         # println( "solution did not converge" )
         dlambda = dlambda/2 ;
         lambda = plambda + dlambda ;
      end

      totalIterations = totalIterations + k ;

      if ( plambda == 1 && stepConverged )
         converged = true ;
         break ;
      end

      if ( lambda >= 1 )
         lambda = 1 ;
      end

      if ( dlambda <= p[ :minStep ] )
         throw( "source load step $dlambda too small (> ", p[ :minStep ], "), function not converging" ) ;
      end
   end

   ecputime = CPUtime_us() - ecputime ;

   if ( converged )
      println( "solution converged after $totalIterations iterations" ) ;
   else
      println( "solution did not converge after $totalIterations iterations" ) ;
   end

   # also return a time domain conversion right out of the box:
   v = zeros( size( V ) ) ;
   for i in 1:R
      v[ i : R : end ] = F * V[ i : R : end ] ;
   end
=#

   # return this function's data along with the return data from HarmonicBalance().
   h = r ;

#=
   h[ :v ]        = v ;
   h[ :V ]        = V ;
=#
   h[ :ecputime ] = ecputime ;
   h[ :omega ]    = omega ;
   h[ :R ]        = R ;

   h ;
end
