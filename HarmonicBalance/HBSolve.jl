type HBSolveParams
   tolF::Float64
   edV::Float64
   JcondTol::Float64
   iterations::Int
   subiterations::Int
   minStep::Float64
   dlambda::Float64
   dispfrequency::Bool
   maxStepMultiples::Int
end

   defp = HBSolveParams( 
         1e-6,    # tolF
         1e-3,    # edV
         1e-23,   # JcondTol
         50,      # iterations
         50,      # subiterations
         0.0001,  # minStep
         0.01,    # dlambda
         1,       # dispfrequency
         50       # maxStepMultiples
         ) ;


# FIXME: introduce parameter construction method that accounts for all this:
   # tolerances
   if ( ~isfield( p, 'tolF' ) )
      p.tolF = defp.tolF ;
   end
   if ( ~isfield( p, 'edV' ) )
      p.edV = defp.edV ;
   end

   # maximum allowed Jacobian Condition
   if ( ~isfield( p, 'JcondTol' ) )
      p.JcondTol = defp.JcondTol ;
   end

   # iteration limits
   if ( ~isfield( p, 'iterations' ) )
      p.iterations = defp.iterations ;
   end
   if ( ~isfield( p, 'subiterations' ) )
      p.subiterations = defp.subiterations ;
   end
   if ( ~isfield( p, 'minStep' ) )
      p.minStep = defp.minStep ;
   end

   if ( ~isfield( p, 'dlambda' ) )
      p.dlambda = defp.dlambda ;
   end

   if ( ~isfield( p, 'maxStepMultiples' ) )
      p.maxStepMultiples = defp.maxStepMultiples ;
   end

   if ( ~isfield( p, 'dispfrequency' ) )
      p.dispfrequency = defp.dispfrequency ;
   end


#=
  Uses the Harmonic Balance Method to solve the
  steady state condtion of the circuit described in p.fileName.

  Harmonic frequencies are limited to N.

  It returns the vector containing the unknowns of the circuit, v, ordered as
  described in HarmonicBalance.jl and the cpu time required to solve the
  circuit using Newton's Method.
=#
function h = HBSolve( N, p )
   r = NodalAnalysis( p.fileName ) ;

   # Harmonic Balance Parameters
   # Only intend on using one frequency for all AC sources
   #omega = min( r.angularVelocities( find ( r.angularVelocities > 0 ) ) ) ;
   omega = min( r.angularVelocities( r.angularVelocities > 0 ) ) ;

   r = HarmonicBalance( r, N, omega ) ;
   R = length( r.G ) ;

   # Newton's Method Parameters
   if ( isfield( p, 'linearInit' ) && p.linearInit && (rcond( r.Y ) > 1e-6) )
      # suggested by wikipedia HB article: use the linear solution
      # as a seed, but this doesn't work out well for some circuits ( i.e. halfWaveRectifier )
      V0 = r.Y\r.I ;
   elseif ( isfield( p, 'complexRandInit' ) && p.complexRandInit )
      V0 = rand( R * ( 2 * N + 1 ), 1 ) + 1j * rand( R * ( 2 * N + 1 ), 1 ) ;
   elseif ( isfield( p, 'randInit' ) && p.randInit )
      V0 = rand( R * ( 2 * N + 1 ), 1 ) ;
   else
      V0 = zeros( R * ( 2 * N + 1 ), 1 ) ;
   end

   totalIterations = 0 ;

   # Source Stepping
   lambda = 0 ;
   plambda = 0 ;
   dlambda = p.dlambda ;
   converged = 0 ;
   ecputime = cputime ;
   for i = 1:p.iterations
      V = V0 ;

      [Inl, JI] = DiodeCurrentAndJacobian( r, V ) ;

      # Function to minimize:
      f = r.Y * V - Inl - lambda * r.I ;

      J = r.Y - JI ;
      jcond = rcond( J ) ;

      # half wave rectifier (and perhaps other circuits) can't converge when lambda == 0.  have to start off bigger.
      if ( 0 == lambda )
         #while ( ( jcond < p.JcondTol ) || isnan( jcond ) )

#         # First fall back to zeros for the initial vector.  Could alternately step that initial vector selection.
#         if ( isnan( jcond ) )
#            V0 = zeros( R * ( 2 * N + 1 ), 1 ) ;
#            V = V0 ;
#            f = r.Y * V - Inl - dlambda * r.I ;
#
#            J = r.Y - JI ;
#            jcond = rcond( J ) ;
#         end
          
         while ( isnan( jcond ) )
            println( "lambda: $dlambda, cond = $jcond" ) ;

            dlambda = dlambda + p.dlambda ;

            f = r.Y * V - Inl - dlambda * r.I ;

            J = r.Y - JI ;
            jcond = rcond( J ) ;

            if ( dlambda > 1 )
               throw( "could not find an initital source load step" ) ;
            end
         end

         lambda = dlambda ;
         plambda = dlambda ;
      end

      if ( 0 == mod(i, p.dispfrequency) )
         println( "iteration $i: lambda: $lambda, |V0| = ", norm( V0 ), ", cond = $jcond" ) ;
      end

      stepConverged = 0 ;

      for k = 1:p.subiterations

         # Newton Iteration Update
         dV = J\-f ;
         V = V + dV ;

         [Inl, JI] = DiodeCurrentAndJacobian( r, V ) ;

         # Function to minimize:
         f = r.Y * V - Inl - lambda * r.I ;

         # Construct Jacobian
         J = r.Y - JI ;
         jcond = rcond( J ) ;

         if ( ( jcond < p.JcondTol ) || isnan( jcond ) )
            stepConverged = 0 ;
            break
         end

         if ( norm( f ) < p.tolF ) || ( norm( dV ) < p.edV )
            stepConverged = 1 ;
            break ;
         end
      end

      if ( stepConverged )
         # println( "solution converged" )
         V0 = V ;

         trialLambda = 2 * dlambda ;

         # don't allow the step size to go too many multiples bigger than the default step size if it has been decreased.
         if ( trialLambda < (p.maxStepMultiples * p.dlambda) )
            dlambda = trialLambda ;
         else
            dlambda = p.dlambda ;
         end

         plambda = lambda ;
         lambda = lambda + dlambda ;
      else
         # println( "solution did not converge" )
         dlambda = dlambda/2 ;
         lambda = plambda + dlambda ;
      end

      totalIterations = totalIterations + k ;

      if ( plambda == 1 && stepConverged == 1 )
         converged = 1 ;
         break ;
      end

      if ( lambda >= 1 )
         lambda = 1 ;
      end

      if ( dlambda <= p.minStep )
#save( 'a.mat' ) ;
         throw( "source load step $dlambda too small (> $(p.minStep)), function not converging" ) ;
      end
   end

   ecputime = cputime - ecputime ;

   if ( converged )
#save( 'b.mat' ) ;
      println( "solution converged after ", num2str( totalIterations ), " iterations " ) ;
   else
      println( "solution did not converge after ", num2str( totalIterations ), " iterations " ) ;
   end

   # return this function's data along with the return data from HarmonicBalance().
   h = r ;
   # also return a time domain conversion right out of the box:
   v = zeros( size( V ) ) ;
   for i = 1:R
      v( i : R : end ) = r.F * V( i : R : end ) ;
   end
   h.v = v ;
   h.V = V ;
   h.ecputime = ecputime ;
   h.omega = omega ;
   h.R = R ;
end
