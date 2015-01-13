-------------------------------------------------------------------
Infrastructure:

   NodalAnalysis.jl

      Parse the netlist file and return the time domain MNA equation matrices and an
      encoding of any non-linear elements.

   FIXME: 1) cell => string array conversion.

   FourierMatrixComplex.jl

      Compute the "Small F" Fourier matrix for the discrete Fourier transform.

      (FIXME: Should use FFT instead)

   HarmonicBalance.jl
      Construct the Frequency domain equivalents of the linear portions of the network.
      Consumes results from NodalAnalysis().

      FIXME: 1) deal with find() call.

   HBSolve.jl
      Harmonic Balance workhorse. 

      FIXME: 1) array references to translate.
      FIXME: 1) min (omega) stuff.

-------------------------------------------------------------------
Solver:

   DiodeNonVdependent.jl

      Precalculate matrices that can be used repeatedly in DiodeCurrentAndJacobian.

   DiodeCurrentAndJacobian.jl

      Do the V dependent parts of the I(V) and J(V) current and Jacobian calculations.

-------------------------------------------------------------------
Plotting and test related:

   PlotWaveforms.jl
      Calls HBSolve() for a netlist file and caches the result.
      Then plots the results using a set of plot specifications.

   TestSolver.jl
      Generates the cputime/error plots

   makefigures.jl
      Driver for all the plots.  Calls PlotWaveforms()

         Has references to saveHelper() to deal with.

-------------------------------------------------------------------
