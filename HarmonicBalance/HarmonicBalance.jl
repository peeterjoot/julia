#=
 HarmonicBalance generates the Harmonic balance modified nodal analysis (MNA) equations from the time domain MNA
 representation.

    Y V = B U = I + ~I,                                           (1)

 where ~I represents non-linear contributions not returned directly as a matrix.

 The Harmonic balance results returned are associated with the time domain equations

    G x(t) + C \dot{x}(t)= B angularVelocities(t) + D nonlinear(t),  (2)

 as returned from HarmonicBalance(),
 where the column vector angularVelocities(t) contains all sources, and x(t) is a vector of all the sources.

 Here V = [
    V_{-N}^(1)
    V_{-N}^(2)
    .
    .
    .
    V_{1-N}^(1)
    V_{1-N}^(2)
    .
    .
    .
    V_{0}^(1)
    V_{0}^(2)
    .
    .
    .
    V_{N-1}^(1)
    V_{N-1}^(2)
    .
    .
    .
    V_{N}^(1)
    V_{N}^(2)
    .
    .
    .
   ]

 is a vector of DFT Fourier coefficients, defined by the transform pair:

     x_k = \sum_{n = -N}^N X_k e^{j omega n t_k}                    (3)
     X_k = (1/(2 N + 1)) \sum_{n = -N}^N x_k e^{-j omega n t_k}     (4)
     t_k = T k/(2 N + 1)                                            (5)
     omega T = 2 pi                                                 (6)

 Y has the block diagonal structure

    Y = [ {G + j omega n}_n \delta_{nm} ]_{nm}                      (7)

---------------------------------------------------------------------------------------

 INPUT PARAMETERS:

 - inputs [Dict]:

    This function consumes all the output parameters of:

       results = NodalAnalyis(...)

    a Dict() return with fields including: G, C, B, angularVelocities, D, nonlinear.

    That output is passed into this function as inputs.

 - N [Int]:

     The number of frequencies to include in the bandwith limited Fourier representation (3)

 - omega [Float64]:

     The base frequency for all the higher level harmonics.

------------------------------------------------

 OUTPUTS:

 With R equal to the total number of MNA variables, the returned parameters

 - results[ :Y ] [array]

    R(2N+1) x R(2N+1) matrix, where the 2N+1 RxR matrices down the diagonal are formed from sums of G's and (j omega n C)'s

 - results[ :I ] [array]

    R x (2 N + 1) matrix of linear source Fourier coefficients.

 - results[ :Vnames ] [cell]

   is an R x (2 N + 1) array of strings for each of the Fourier coefficient variables in the frequency domain equations.

   The R entries are composed of:
   - Entries for each node voltage in the system.
   - Entries for each current variable flowing through a voltage source, a voltage
     controlled voltage source, an inductor, or a diode (this last also treated as a current source).
     When there are diodes, there will also be a non-linear portion of the diode model to handle separately.

------------------------------------------------
=#

function HarmonicBalance( inputs, N, omega )

   results = inputs ;    # return these for convienence.

   G                 = inputs[ :G ] ;
   C                 = inputs[ :C ] ;
   B                 = inputs[ :B ] ;
   angularVelocities = inputs[ :angularVelocities ] ;
   xnames            = inputs[ :xnames ] ;

   traceit( "N = $N, omega: $omega" ) ;

   twoNplusOne = 2 * N + 1 ;

   R = size( G, 1 ) ;
   szG = size( G ) ;
   if ( R != size(G, 2) )
      throw( "HarmonicBalance:squareCheck: expected G ($szG) to be square" ) ;
   end

   Y = zeros( Complex{Float64}, twoNplusOne * R, twoNplusOne * R ) ;
   Vnames = Array( String, twoNplusOne * R, 1 ) ;
   II = zeros( Complex{Float64}, twoNplusOne * R, 1 ) ;

   jOmega = im * omega ;

   r = 0 ;
   s = 0 ;
   q = 0 ;
   for n in -N:N
      for m in 1:R
         r = r + 1 ;
         xm = xnames[m] ;
         Vnames[r] = "$xm:$n" ;
      end

      Y[ s+1:s+R, s+1:s+R ] = G + jOmega * n * C ;
      s = s + R ;

      thisOmega = omega * n ;
      omegaIndex = findin( angularVelocities, thisOmega ) ;

      nu0 = omega/(2 * pi) ;
      traceit( "HarmonicBalance: n=$n, nu_0 = $nu0, omegaIndex = $omegaIndex" ) ;

      if ( length(omegaIndex) != 0 )
         # found one:

         II[ q+1:q+R ] = B[ :, omegaIndex ] ;
      else
         # Not an error to not find a matching frequency.  Our input sources may not have all the frequencies that
         # we allow in our bandwidth limited Harmonic Balance DFT representation.

         #traceit( "HarmonicBalance: no omega match from: $angularVelocities" ) ;
      end
      q = q + R ;
   end

   results[ :Y ] = Y ;
   results[ :I ] = II ;
   results[ :Vnames ] = Vnames ;

   #-----------------
   # precalculate the Fourier transform matrix pairs and cache them:
   F = FourierMatrixComplex( N ) ;

   Finv = conj( F )/ twoNplusOne ;

   results[ :F ] = F ;
   results[ :Finv ] = Finv ;
   #-----------------

   nm = DiodeNonVdependent( results ) ;
   results[ :nonlinearMatrices ] = nm ;

   #-----------------

   results ;
end
