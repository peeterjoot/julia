workspace()

using pd ;
using Netlist ;

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
 
  - results.G [array]
 
     RxR matrix of resistance stamps.
 
  - results.C [array]
 
     RxR matrix of stamps for the time dependent portion of the MNA equations.
 
  - results.B [array]
 
     RxM matrix of constant source terms.  Each column encodes the current sources
     for increasing frequencies.  For example, if there are DC sources in
     the circuit the first column would have contributions from the DC sources,
     and any columns after that would be for higher frequencies.
 
  - results.angularVelocities [array]
 
     Mx1 matrix of angular velocities ( 2 pi freq, where freq is from an AC current
     or voltage line specification ), ordered from lowest to highest, including
     both negative and positive frequencies for any given AC signal.  M is the number of
     AC sources (times 2), plus one if there are are any DC sources.
 
     A zero value in one of the angularVelocities vector positions represents a DC source.
 
  - results.xnames [cell]
 
    is an Rx1 array of strings for each of the variables in the resulting system.
    Entries will be added to this for each node voltage in the system.
    Current variables will be added for each DC voltage source, each DC voltage
    controlled voltage source, as well as any inductor currents.
 
  - results.nonlinear [array of struct]
 
    An Sx1 array that encodes all the non-linear source information, where S is the number
    of non-linear sources.
 
  - results.D [array]
 
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

   i = parser( filename ) ;

   biggestNodeNumber = max( i.allNodes... ) ;
   allfrequencies = negativeAndPositiveFrequencies( i.allFrequencies ) ;

   angularVelocities = 2 * pi * allfrequencies ;

   traceit( "maxnode: $biggestNodeNumber, freq: $allfrequencies" ) ;

   numVoltageSources = length( i.voltage ) ;
   numAmpSources = length( i.amplifier ) ;
   numIndSources = length( i.inductor ) ;

   numAdditionalSources = numVoltageSources + numAmpSources + numIndSources ;

   # have to adjust these sizes for sources, and voltage control sources
   G = spzeros( biggestNodeNumber + numAdditionalSources, biggestNodeNumber + numAdditionalSources ) ;
   C = spzeros( biggestNodeNumber + numAdditionalSources, biggestNodeNumber + numAdditionalSources ) ;

   numFrequencies = length( allfrequencies ) ;

   B = spzeros( biggestNodeNumber + numAdditionalSources, numFrequencies ) ;

   xnames = cell( biggestNodeNumber + numAdditionalSources ) ;
   for k in 1:biggestNodeNumber
      xnames[k] = "V_$k" ;
   end

println( "$xnames" ) ;

# THE REST IS ALL ACTUALLY MATLAB CODE, TO BE REWRITTEN IN JULIA.  NEXT, FIGURE OUT SYNTAX FOR cell (Any ?) array.
#=

   # process the resistor lines:
   # note: matlab for loop appears to iterate over matrix by assigning each column to a temp variable
   labelNumber = 0 ;
   for res = resistorLines
      labelNumber = labelNumber + 1 ;
      label     = resistorLables{labelNumber} ;
      plusNode  = res(1) ;
      minusNode = res(2) ;
      z         = 1/res(3) ;

      traceit( '%s %d,%d -> %d\n', label, plusNode, minusNode, 1/z ) ) ;

      # insert the stamp:
      if ( plusNode )
         G( plusNode, plusNode ) = G( plusNode, plusNode ) + z ;
         if ( minusNode )
            G( plusNode, minusNode ) = G( plusNode, minusNode ) - z ;
            G( minusNode, plusNode ) = G( minusNode, plusNode ) - z ;
         end
      end
      if ( minusNode )
         G( minusNode, minusNode ) = G( minusNode, minusNode ) + z ;
      end
   end

   # process the capacitor lines:
   labelNumber = 0 ;
   for cap = capLines
      labelNumber = labelNumber + 1 ;
      label     = capLables{labelNumber} ;
      plusNode  = cap(1) ;
      minusNode = cap(2) ;
      cv        = cap(3) ;

      traceit( sprintf( '%s %d,%d -> %d\n', label, plusNode, minusNode, cv ) ) ;

      # insert the stamp:
      if ( plusNode )
         C( plusNode, plusNode ) = C( plusNode, plusNode ) + cv ;
         if ( minusNode )
            C( plusNode, minusNode ) = C( plusNode, minusNode ) - cv ;
            C( minusNode, plusNode ) = C( minusNode, plusNode ) - cv ;
         end
      end
      if ( minusNode )
         C( minusNode, minusNode ) = C( minusNode, minusNode ) + cv ;
      end
   end

   # process the voltage sources:
   r = biggestNodeNumber ;
   labelNumber = 0 ;
   for vol = voltageLines
      r = r + 1 ;
      labelNumber     = labelNumber + 1 ;
      label           = voltageLables{labelNumber} ;
      plusNode        = vol(1) ;
      minusNode       = vol(2) ;
      magnitude       = vol(3) ;
      omega           = vol(4) ;
      phi             = vol(5) ;

      traceit( sprintf( '%s %d,%d -> %d (%e, %e)\n', label, plusNode, minusNode, magnitude, omega, phi ) ) ;
      xnames{r} = sprintf( 'i_{%s_{%d,%d}}', label, minusNode, plusNode ) ;

      if ( plusNode )
         G( r, plusNode ) = 1 ;
         G( plusNode, r ) = -1 ;
      end
      if ( minusNode )
         G( r, minusNode ) = -1 ;
         G( minusNode, r ) = 1 ;
      end

      # V,omega,phi => V cos( omega t - phi ) = e^{ j omega t - j phi } * V/2 + e^{-j omega t + j phi } * V/2

      omegaIndex = find( angularVelocities == omega ) ;

      if ( size(omegaIndex) ~= size(1) )
         error( 'NodalAnalysis:find', 'failed to find angular velocity %e in angularVelocities: %s', omega, mat2str(angularVelocities) ) ;
      end

      if ( omega == 0 )
         B( r, omegaIndex ) = B( r, omegaIndex ) + magnitude ;
      else
         B( r, omegaIndex ) = B( r, omegaIndex ) + magnitude * exp( - 1j * phi )/2 ;

         omegaIndex = find( angularVelocities == -omega ) ;
         if ( size(omegaIndex) ~= size(1) )
            error( 'NodalAnalysis:find', 'failed to find angular velocity %e in angularVelocities: %s', -omega, mat2str(angularVelocities) ) ;
         end

         B( r, omegaIndex ) = B( r, omegaIndex ) + magnitude * exp( 1j * phi )/2 ;
      end
   end

   nlIndex = 0 ;
   numberOfDiodes = size( diodeLines, 2 ) ;
   numberOfPowers = size( powerLines, 2 ) ;

   D = zeros( size(B, 1), 1, 'like', G ) ;
   nonlinear = cell( numberOfDiodes + numberOfPowers + numberOfNonlinearGains, 1 ) ;

   # value for r (fall through from loop above)
   # process the voltage controlled lines
   labelNumber = 0 ;
   for amp = ampLines
      r = r + 1 ;
      labelNumber = labelNumber + 1 ;

      label                = ampLables{labelNumber} ;
      plusNodeNum          = amp(1) ;
      minusNodeNum         = amp(2) ;
      plusControlNodeNum   = amp(3) ;
      minusControlNodeNum  = amp(4) ;
      gain                 = amp(5) ;
      vt                   = amp(6) ;
      alpha                = amp(7) ;

      traceit( sprintf( '%s %d,%d (%d,%d) -> %d\n', label, plusNodeNum, minusNodeNum, plusControlNodeNum, minusControlNodeNum, gain ) ) ;

      if ( minusNodeNum )
         G( r, minusNodeNum ) = 1 ;
         G( minusNodeNum, r ) = -1 ;
      end
      if ( plusNodeNum )
         G( r, plusNodeNum ) = -1 ;
         G( plusNodeNum, r ) = 1 ;
      end

      if ( 1 == alpha )
         if ( plusControlNodeNum )
            G( r, plusControlNodeNum ) = gain/vt ;
         end
         if ( minusControlNodeNum )
            G( r, minusControlNodeNum ) = -gain/vt ;
         end
      else
         nlIndex = nlIndex + 1 ;

         nonlinear{ nlIndex } = struct( 'io', gain, 'type', 'power', 'vt', vt, 'vp', plusControlNodeNum, 'vn', minusControlNodeNum, 'exponent', alpha ) ;

         D( r, nlIndex ) = -1 ;
      end

      xnames{r} = sprintf( 'i_{%s_{%d,%d}}', label, plusNodeNum, minusNodeNum ) ;
   end

   # value for r (fall through from loop above)
   # process the inductors:
   labelNumber = 0 ;
   for ind = indLines
      r = r + 1 ;
      labelNumber = labelNumber + 1 ;
      label       = indLables{labelNumber} ;
      plusNode    = ind(1) ;
      minusNode   = ind(2) ;
      value       = ind(3) ;

      traceit( sprintf( '%s %d,%d -> %d\n', label, plusNode, minusNode, value ) ) ;

      if ( plusNode )
         G( r, plusNode ) = -1 ;
         G( plusNode, r ) = 1 ;
      end
      if ( minusNode )
         G( r, minusNode ) = 1 ;
         G( minusNode, r ) = -1 ;
      end

      C( r, r ) = value ;

      xnames{r} = sprintf( 'i_{%s_{%d,%d}}', label, plusNode, minusNode ) ;
   end

   # process the current sources:
   labelNumber = 0 ;
   for cur = currentLines
      labelNumber     = labelNumber + 1 ;
      label           = currentLables{labelNumber} ;
      plusNode        = cur(1) ;
      minusNode       = cur(2) ;
      magnitude       = cur(3) ;
      omega           = cur(4) ;
      phi             = cur(5) ;

      traceit( sprintf( '%s %d,%d -> %d (%e, %e)\n', label, plusNode, minusNode, magnitude, omega, phi ) ) ;

      # V,omega,phi => V cos( omega t - phi ) = e^{ j omega t - j phi } * V/2 + e^{-j omega t + j phi } * V/2

      omegaIndex = find( angularVelocities == omega ) ;
      if ( size(omegaIndex) ~= size(1) )
         error( 'NodalAnalysis:find', 'failed to find angular velocity %e in angularVelocities: %s', omega, mat2str(angularVelocities) ) ;
      end

      if ( omega == 0 )
         if ( plusNode )
            B( plusNode, omegaIndex ) = B( plusNode, omegaIndex ) - magnitude ;
         end
         if ( minusNode )
            B( minusNode, omegaIndex ) = B( minusNode, omegaIndex ) + magnitude ;
         end
      else
         if ( plusNode )
            B( plusNode, omegaIndex ) = B( plusNode, omegaIndex ) - magnitude * exp( - 1j * phi )/2 ;
         end
         if ( minusNode )
            B( minusNode, omegaIndex ) = B( minusNode, omegaIndex ) + magnitude * exp( - 1j * phi )/2 ;
         end

         omegaIndex = find( angularVelocities == -omega ) ;

         if ( size(omegaIndex) ~= size(1) )
            error( 'NodalAnalysis:find', 'failed to find angular velocity %e in angularVelocities: %s', -omega, mat2str(angularVelocities) ) ;
         end

         if ( plusNode )
            B( plusNode, omegaIndex ) = B( plusNode, omegaIndex ) - magnitude * exp( 1j * phi )/2 ;
         end
         if ( minusNode )
            B( minusNode, omegaIndex ) = B( minusNode, omegaIndex ) + magnitude * exp( 1j * phi )/2 ;
         end
      end
   end

   # process the diode sources:
   labelNumber = 0 ;
   for dio = diodeLines
      labelNumber = labelNumber + 1 ;
      label       = diodeLables{labelNumber} ;
      plusNode    = dio(1) ;
      minusNode   = dio(2) ;
      io          = dio(3) ;
      vt          = dio(4) ;
      nlIndex = nlIndex + 1 ;

      traceit( sprintf( '%s %d,%d -> %d\n', label, plusNode, minusNode, -io ) ) ;

      omegaIndex = find( angularVelocities == 0 ) ;
      if ( size(omegaIndex) ~= size(1) )
         error( 'NodalAnalysis:find', 'failed to find DC frequency entry in angularVelocities: %s', -omega, mat2str(angularVelocities) ) ;
      end

      nonlinear{ nlIndex } = struct( 'io', -io, 'type', 'exp', 'vt', vt, 'vp', plusNode, 'vn', minusNode ) ;
      if ( plusNode )
         B( plusNode, omegaIndex ) = B( plusNode, omegaIndex ) + io ;
         D( plusNode, nlIndex ) = 1 ;
      end
      if ( minusNode )
         B( minusNode, omegaIndex ) = B( minusNode, omegaIndex ) - io ;
         D( minusNode, nlIndex ) = -1 ;
      end
   end

   # process the power law elements:
   labelNumber = 0 ;

   for pow = powerLines
      labelNumber = labelNumber + 1 ;
      label       = powerLables{labelNumber} ;
      plusNode    = pow(1) ;
      minusNode   = pow(2) ;
      io          = pow(3) ;
      vt          = pow(4) ;
      alpha       = pow(5) ;
      nlIndex = nlIndex + 1 ;

      traceit( sprintf( '%s %d,%d -> %e, %e, %e\n', label, plusNode, minusNode, io, vt, alpha ) ) ;

      nonlinear{ nlIndex } = struct( 'io', -io, 'type', 'power', 'vt', vt, 'vp', plusNode, 'vn', minusNode, 'exponent', alpha ) ;
      if ( plusNode )
         D( plusNode, nlIndex ) = 1 ;
      end
      if ( minusNode )
         D( minusNode, nlIndex ) = -1 ;
      end
   end

   results = struct( 'G', G, 'C', C, 'B', B, 'angularVelocities', angularVelocities, 'D', D, 'xnames', {xnames}, 'nonlinear', {nonlinear} ) ;
=#
end

#=
   Take a sorted array like (0,1,2) or (1,3,4), and add all the negative frequencies.
=#
function negativeAndPositiveFrequencies( freq )
   fr = abs( freq ) ;

   firstNonZeroIndex = int( fr[1] < 1 ) + 1 ;
   frPlus = fr[ firstNonZeroIndex:end ] ;

# two other more elegant ways, but much slower since the array is already sorted.
# better ways: http://stackoverflow.com/a/27884583/189270
#   frPlus = filter( x -> x > 0, fr ) ;
#   frPlus = fr[ fr. > 0 ] ;
# both of these are _much_ slower (see time_elementwise.jl)

   push!( fr, -frPlus... ) ;
   allfrequencies = sort( fr ) ;
end
