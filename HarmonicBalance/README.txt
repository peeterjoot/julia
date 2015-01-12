PORTED: 
-------------------------------------------------------------------
Infrastructure:

   NodalAnalysis.jl

      Parse the netlist file and return the time domain MNA equation matrices and an
      encoding of any non-linear elements.

-------------------------------------------------------------------

STARTED:
-------------------------------------------------------------------

   HarmonicBalance.jl
      Construct the Frequency domain equivalents of the linear portions of the network.
      Consumes results from NodalAnalysis().

-------------------------------------------------------------------

... some new Julia specific FIXMEs to deal with.


TODO: 
-------------------------------------------------------------------

   FourierMatrixComplex.m

      Compute the "Small F" Fourier matrix for the discrete Fourier transform.... use FFT instead.

   DiodeCurrentAndJacobian.m

      Do the V dependent parts of the I(V) and J(V) current and Jacobian calculations.

   DiodeNonVdependent.m

      Precalculate matrices that can be used repeatedly in DiodeCurrentAndJacobian.

-------------------------------------------------------------------
Plotting and test related:

   TestSolver.m
      Generates the cputime/error plots

   PlotWaveforms.m
      Calls HBSolve() or NewtonsHarmonicBalance() for a netlist file and caches the result.
      Then plots the results using a set 
      of plot specifications.

   makefigures.m
      Driver for all the plots.  Calls PlotWaveforms()

-------------------------------------------------------------------