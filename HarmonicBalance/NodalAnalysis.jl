#workspace()
#
#using pd ;
#using Netlist ;
#using SparseUtil ;

type NonlinearElement_T
   typeDesc::Symbol
   vp::Int
   vn::Int
   vt::Float64
   magnitude::Float64
   exponent::Float64
end

#=
   Take a sorted array like (0,1,2) or (1,3,4), and add all the negative frequencies.
=#
function negativeAndPositiveFrequencies( freq )
   fr = abs( freq ) ;

   firstNonZeroIndex = Int( fr[1] < 1 ) + 1 ;
   frPlus = fr[ firstNonZeroIndex:end ] ;

# From http://stackoverflow.com/a/27884583/189270
#
# Two other more elegant ways, but much slower since the array is already sorted.
# Timed these out of curiousity in time_elementwise.jl
#
#   frPlus = filter( x -> x > 0, fr ) ;
#   frPlus = fr[ fr. > 0 ] ;

   # Calling push! with zero length array seems to cause deprecated warning in julia 0.4
   # Trying that manually in the REPL in julia 0.3 causes error?
   #
   # Looks like it's best to avoid that unconditionally:
   #
   if ( length(frPlus) != 0 )
      #println("fr: $fr ; frPlus: $frPlus") ;
      push!( fr, -frPlus... ) ;
   end

   sort( fr ) ; # return
end

#=
  NodalAnalysis generates the modified nodal analysis (MNA) equations from a text file
 
  This is based on NodalAnalysis.m from ps3a (which included RLC support), and has been generalized to add support
  for non-DC sources and diodes.
 
  This routine [G, C, B, angularVelocities, x] = NodalAnalysis(filename)
  generates the modified nodal analysis (MNA) equations
 
     G x(t) + C \dot{x}(t)= B u(t) + D n(t)
 
  Here:
     - x(t) is a column vector of all the sources. [returned as xnames]
     - u(t) is a column vector of all the linear sources. [returned as angularVelocities]
     - n(t) is a column vector of all the non-linear sources. [returned as nonlinear]

 ------------------------------------------------
 
  OUTPUT VARIABLES:
 
  With R equal to the total number of MNA variables, the returned parameters are
 
  - results[ :G ] [array]
 
     RxR matrix of resistance stamps.
 
  - results[ :C ] [array]
 
     RxR matrix of stamps for the time dependent portion of the MNA equations.
 
  - results[ :B ] [array]
 
     RxM matrix of constant source terms.  Each column encodes the current sources
     for increasing frequencies.  For example, if there are DC sources in
     the circuit the first column would have contributions from the DC sources,
     and any columns after that would be for higher frequencies.
 
  - results[ :angularVelocities ] [array]
 
     Mx1 matrix of angular velocities ( 2 pi freq, where freq is from an AC current
     or voltage line specification ), ordered from lowest to highest, including
     both negative and positive frequencies for any given AC signal.  M is the number of
     AC sources (times 2), plus one if there are are any DC sources.
 
     A zero value in one of the angularVelocities vector positions represents a DC source.
 
  - results[ :xnames ] [cell]
 
    is an Rx1 array of strings for each of the variables in the resulting system.
    Entries will be added to this for each node voltage in the system.
    Current variables will be added for each DC voltage source, each DC voltage
    controlled voltage source, as well as any inductor currents.
 
  - results[ :nonlinear ] [array of NonlinearElement_T]
 
    An Sx1 array that encodes all the non-linear source information, where S is the number
    of non-linear sources.
 
  - results[ :D ] [array]
 
    is an RxS matrix.  The i-th column of D contains the magnitudes of the contributions
    of the i-th non-linear source.  For example, if the i'th (diode) source is:
 
    i_d = I_0 ( e^{(v1 -v2)/V_T} - 1 )
 
    Then there will be +- 1 values in the i-th column of D associated with the I_0 e^{(v1 -v2)/V_T}
    portion of this current source.  The constant portion of these -+ I_0 values will be stored in the
    matrix B associated with a zero-frequency (linear) source.  These columns are not scaled by
    each of the I_0 values, which are returned in nonlinear.
 
  All of G,C,B,D are returned as sparse matrices since they can potentially have many zeros.
 
 ------------------------------------------------
=#
function NodalAnalysis( filename )

   li = parser( filename ) ;

   biggestNodeNumber = max( li.allNodes... ) ;
   angularVelocities = negativeAndPositiveFrequencies( li.allFrequencies ) ;

   traceit( "maxnode: $biggestNodeNumber, freq: $angularVelocities" ) ;

   numVoltageSources = length( li.voltage ) ;
   numAmpSources = length( li.amplifier ) ;
   numIndSources = length( li.inductor ) ;

   numAdditionalSources = numVoltageSources + numAmpSources + numIndSources ;

   # have to adjust these sizes for sources, and voltage control sources
   G = spzeros( biggestNodeNumber + numAdditionalSources, biggestNodeNumber + numAdditionalSources ) ;
   C = spzeros( biggestNodeNumber + numAdditionalSources, biggestNodeNumber + numAdditionalSources ) ;

   numFrequencies = length( angularVelocities ) ;

   B = spzerosT( biggestNodeNumber + numAdditionalSources, numFrequencies, 0.0 + im ) ;

   xnames = Array( String, biggestNodeNumber + numAdditionalSources ) ;
   for k in 1:biggestNodeNumber
      xnames[k] = "V_$k" ;
   end

   # process the resistor lines:
   # note: matlab for loop appears to iterate over matrix by assigning each column to a temp variable
   for res in li.resistor
      plusNode  = res.node1 ;
      minusNode = res.node2 ;
      r         = res.value ;
      z         = 1/r ;

      #println( "$r" ) ;

      # insert the stamp:
      if ( plusNode != 0 )
         G[ plusNode, plusNode ] = G[ plusNode, plusNode ] + z ;
         if ( minusNode != 0 )
            G[ plusNode, minusNode ] = G[ plusNode, minusNode ] - z ;
            G[ minusNode, plusNode ] = G[ minusNode, plusNode ] - z ;
         end
      end
      if ( minusNode != 0 )
         G[ minusNode, minusNode ] = G[ minusNode, minusNode ] + z ;
      end
   end

   # process the capacitor lines:
   for cap in li.capacitor
      plusNode  = cap.node1 ;
      minusNode = cap.node2 ;
      cv        = cap.value ;

      #println( "$r" ) ;

      # insert the stamp:
      if ( plusNode != 0 )
         C[ plusNode, plusNode ] = C[ plusNode, plusNode ] + cv ;
         if ( minusNode != 0 )
            C[ plusNode, minusNode ] = C[ plusNode, minusNode ] - cv ;
            C[ minusNode, plusNode ] = C[ minusNode, plusNode ] - cv ;
         end
      end
      if ( minusNode != 0 )
         C[ minusNode, minusNode ] = C[ minusNode, minusNode ] + cv ;
      end
   end

   # process the voltage sources:
   r = biggestNodeNumber ;
   for vol in li.voltage
      r = r + 1 ;
      lt              = vol.lableText ;
      plusNode        = vol.node1 ;
      minusNode       = vol.node2 ;
      magnitude       = vol.value ;
      omega           = vol.omega ;
      phi             = vol.phase ;

      xnames[r] = "i_{V$(lt)_{$minusNode,$plusNode}}" ;

      if ( plusNode != 0 )
         G[ r, plusNode ] = 1 ;
         G[ plusNode, r ] = -1 ;
      end
      if ( minusNode != 0 )
         G[ r, minusNode ] = -1 ;
         G[ minusNode, r ] = 1 ;
      end

      # V,omega,phi => V cos( omega t - phi ) = e^{ j omega t - j phi } * V/2 + e^{-j omega t + j phi } * V/2

      omegaIndex = findin( angularVelocities, omega ) ;

      if ( length(omegaIndex) == 0 )
         throw( "failed to find angular velocity $omega in angularVelocities: $angularVelocities" ) ;
      end

      if ( omega == 0 )
         B[ r, omegaIndex ] = B[ r, omegaIndex ] + magnitude ;
      else
         B[ r, omegaIndex ] = B[ r, omegaIndex ] + magnitude * exp( - im * phi )/2 ;

         omegaIndex = findin( angularVelocities, -omega ) ;
         if ( length(omegaIndex) == 0 )
            throw( "failed to find angular velocity -$omega in angularVelocities: $angularVelocities" ) ;
         end

         B[ r, omegaIndex ] = B[ r, omegaIndex ] + magnitude * exp( im * phi )/2 ;
      end
   end

   nlIndex = 0 ;
   numberOfDiodes = length( li.diode ) ;
   numberOfPowers = length( li.power ) ;

   D = spzeros( size(B, 1), numberOfDiodes + numberOfPowers + li.numberOfNonlinearGains ) ;

   # this will end up with as many rows as D has columns:
   nonlinear = NonlinearElement_T[] ;

   # value for r (fall through from loop above)
   # process the voltage controlled lines
   for amp in li.amplifier
      r = r + 1 ;

      lt                   = amp.lableText ;
      plusNodeNum          = amp.node1 ;
      minusNodeNum         = amp.node2 ;
      plusControlNodeNum   = amp.nc1 ;
      minusControlNodeNum  = amp.nc2 ;
      gain                 = amp.gain ;
      vt                   = amp.vt ;
      alpha                = amp.exponent ;

      #println( "$amp" ) ;

      if ( minusNodeNum != 0 )
         G[ r, minusNodeNum ] = 1 ;
         G[ minusNodeNum, r ] = -1 ;
      end
      if ( plusNodeNum != 0 )
         G[ r, plusNodeNum ] = -1 ;
         G[ plusNodeNum, r ] = 1 ;
      end

      if ( 1.0 == alpha )
         if ( plusControlNodeNum != 0 )
            G[ r, plusControlNodeNum ] = gain/vt ;
         end
         if ( minusControlNodeNum != 0 )
            G[ r, minusControlNodeNum ] = -gain/vt ;
         end
      else
         nlIndex = nlIndex + 1 ;

         n = NonlinearElement_T( :POWER, plusControlNodeNum, minusControlNodeNum, vt, gain, alpha ) ;

         push!( nonlinear, n ) ;

         D[ r, nlIndex ] = -1 ;
      end

      xnames[r] = "i_{E$(lt)_{$plusNodeNum,$minusNodeNum}}" ;
   end

   # value for r (fall through from loop above)
   # process the inductors:
   for ind in li.inductor
      r = r + 1 ;

      lt          = ind.lableText ;
      plusNode    = ind.node1 ;
      minusNode   = ind.node2 ;
      value       = ind.value ;

      #println( "$ind" ) ;

      if ( plusNode != 0 )
         G[ r, plusNode ] = -1 ;
         G[ plusNode, r ] = 1 ;
      end
      if ( minusNode != 0 )
         G[ r, minusNode ] = 1 ;
         G[ minusNode, r ] = -1 ;
      end

      C[ r, r ] = value ;

      xnames[r] = "i_{E$(lt)_{$plusNode,$minusNode}}" ;
   end

   # process the current sources:
   for cur in li.current
      plusNode        = cur.node1 ;
      minusNode       = cur.node2 ;
      magnitude       = cur.value ;
      omega           = cur.omega ;
      phi             = cur.phase ;

      #println( "$cur" ) ;

      # V,omega,phi => V cos( omega t - phi ) = e^{ j omega t - j phi } * V/2 + e^{-j omega t + j phi } * V/2

      omegaIndex = findin( angularVelocities, omega ) ;
      if ( length(omegaIndex) == 0 )
         throw( "NodalAnalysis:failed to find angular velocity $omega in $angularVelocities" ) ;
      end

      if ( omega == 0 )
         if ( plusNode != 0 )
            B[ plusNode, omegaIndex ] = B[ plusNode, omegaIndex ] - magnitude ;
         end
         if ( minusNode != 0 )
            B[ minusNode, omegaIndex ] = B[ minusNode, omegaIndex ] + magnitude ;
         end
      else
         if ( plusNode != 0 )
            B[ plusNode, omegaIndex ] = B[ plusNode, omegaIndex ] - magnitude * exp( - im * phi )/2 ;
         end
         if ( minusNode != 0 )
            B[ minusNode, omegaIndex ] = B[ minusNode, omegaIndex ] + magnitude * exp( - im * phi )/2 ;
         end

         omegaIndex = findin( angularVelocities, -omega ) ;

         if ( length(omegaIndex) == 0 )
            throw( "NodalAnalysis:failed to find angular velocity -$omega in $angularVelocities" ) ;
         end

         if ( plusNode != 0 )
            B[ plusNode, omegaIndex ] = B[ plusNode, omegaIndex ] - magnitude * exp( im * phi )/2 ;
         end
         if ( minusNode != 0 )
            B[ minusNode, omegaIndex ] = B[ minusNode, omegaIndex ] + magnitude * exp( im * phi )/2 ;
         end
      end
   end

   # process the diode sources:
   for dio in li.diode
      plusNode    = dio.node1 ;
      minusNode   = dio.node2 ;
      io          = dio.io ;
      vt          = dio.vt ;
      nlIndex = nlIndex + 1 ;

      #println( "$dio" ) ;

      omegaIndex = findin( angularVelocities, 0 ) ;
      if ( length(omegaIndex) == 0 )
         throw( "NodalAnalysis:failed to find DC frequency entry in $angularVelocities" ) ;
      end

      n = NonlinearElement_T( :EXPONENT, plusNode, minusNode, vt, io, 0.0 ) ;

      push!( nonlinear, n ) ;
      if ( plusNode != 0 )
         B[ plusNode, omegaIndex ] = B[ plusNode, omegaIndex ] + io ;
         D[ plusNode, nlIndex ] = 1 ;
      end
      if ( minusNode != 0 )
         B[ minusNode, omegaIndex ] = B[ minusNode, omegaIndex ] - io ;
         D[ minusNode, nlIndex ] = -1 ;
      end
   end

   # process the power law elements:
   for pow in li.power
      plusNode    = pow.node1 ;
      minusNode   = pow.node2 ;
      io          = pow.io ;
      vt          = pow.vt ;
      alpha       = pow.exponent ;
      nlIndex = nlIndex + 1 ;

      #println( "$pow" ) ;

      n = NonlinearElement_T( :POWER, plusNode, minusNode, vt, io, alpha ) ;

      push!( nonlinear, n ) ;

      if ( plusNode != 0 )
         D[ plusNode, nlIndex ] = 1 ;
      end
      if ( minusNode != 0 )
         D[ minusNode, nlIndex ] = -1 ;
      end
   end

   Dict(
      :G                 => G,
      :C                 => C,
      :B                 => B,
      :angularVelocities => angularVelocities,
      :D                 => D,
      :xnames            => xnames,
      :nonlinear         => nonlinear
   ) ;
end
