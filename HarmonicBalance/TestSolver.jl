function r = TestSolver( p )
   % Calls a Harmonic Balance solution function to solve the
   % circuit described in fileName using the Harmonic Balance method,
   % truncating the harmonics to N multiples of fundamental.
   % The circuit is solved for varying values of N and the cputime required
   % to solve and the maximum error between the solution and a solution of
   % 'sufficiently large' N is computed

%   clear
%   clc

   % Reference Harmonic Balance Parameters
   Nref = 100 ;
   h = HBSolve( Nref, p ) ;
   %xref        = h.v ;
   Xref        = h.V ;
   ecputimeref = h.ecputime ;
   omegaref    = h.omega ;
   %Rref        = h.R ;

   f0ref = omegaref/( 2 * pi ) ;
   Tref = 1/f0ref ;
   %dtref = Tref/( 2 * Nref + 1 ) ;
   %kref = -Nref:Nref ;
   %tref = dtref * kref ;

   Nvalues = [ 1  5  9 10 50 90 ] ;

   % M tests
   M = length( Nvalues ) ;
   ecputimeValues = zeros( M, 1 ) ;
   errorValues = zeros( M, 1 ) ;
   n = 0 ;
   for N = Nvalues
      hn = HBSolve( N, p ) ;
      %v        = hn.v ;
      V        = hn.V ;
      ecputime = hn.ecputime ;
      omega    = hn.omega ;
      R        = hn.R ;

      % Harmonic Balance Parameters
      f0 = omega/( 2 * pi ) ;
      T = 1/f0 ;
      %dt = T/( 2 * N + 1 ) ;
      %k = -N:N ;
      %t = dt * k' ;

      % Determine error in the frequency domain to avoid time scaling issues
      % Need to zero pad the truncated soltuion
      Xz = [ zeros( R * ( Nref - N ), 1 ) ; V ; zeros( R * ( Nref - N ), 1 ) ] ;
      eX = norm( Xz - Xref ) ;
      n = n + 1 ;
      errorValues( n ) = eX ;
      ecputimeValues( n ) = ecputime ;
   end
   Nvalues = [ Nvalues Nref ] ;
   errorValues = [ errorValues ; 0 ] ;
   ecputimeValues = [ ecputimeValues ; ecputimeref ] ;

   r = struct( 'Nvalues', Nvalues, 'errorValues', errorValues, 'ecputimeValues', ecputimeValues ) ;
end
