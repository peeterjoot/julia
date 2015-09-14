-------------------------------------------------------------------

Status: 

Tests: ps1a.jl: (manual) pass.  compared to matlab results.

Re-test HB code, and see if non-convergence issues are fixed after handling Ennn
parsing/handling.

-------------------------------------------------------------------

How to run this:

   workspace()

   # LOAD_PATH FOR julia 0.4:
   push!(LOAD_PATH, pwd()) ; using HB ; include("makefigures.jl")

... hit errors that I thought might be due to rcond() "implementation" (myrcond).  but testing with:

x = [1 1e-14 ; 1 1e-8]

in matlab and Julia look like matlab's rcond() == Julia's 1/cond().

Wonder if this is

- types (initializing as zeros, not complex zeros)?
- scoping?

-------------------------------------------------------------------

Lint with (0.3)

using Lint
lintfile("HB.jl")

-------------------------------------------------------------------
Infrastructure:

   NodalAnalysis.jl

      Parse the netlist file and return the time domain MNA equation matrices and an
      encoding of any non-linear elements.

   FourierMatrixComplex.jl

      Compute the "Small F" Fourier matrix for the discrete Fourier transform.

      (Should use FFT instead)

   HarmonicBalance.jl
      Construct the Frequency domain equivalents of the linear portions of the network.
      Consumes results from NodalAnalysis().

      FIXME: 1) deal with find() call. ... have findin, not find?

   HBSolve.jl
      Harmonic Balance workhorse. 

      FIXME: 1) array references to translate. ... what did I mean by that.
      FIXME: 2) min (omega) stuff.

      See there's a bunch of stuff commented out.

-------------------------------------------------------------------
Solver:

   DiodeNonVdependent.jl

      Precalculate matrices that can be used repeatedly in DiodeCurrentAndJacobian.

   DiodeCurrentAndJacobian.jl

      Do the V dependent parts of the I(V) and J(V) current and Jacobian calculations.

-------------------------------------------------------------------
Plotting and test related:

   TestSolver.jl
      Generates the cputime/error plots

   PlotWaveforms.jl
      Calls HBSolve() for a netlist file and caches the result.
      Then plots the results using a set of plot specifications.

      FIXME: 1) won't work as is.

   makefigures.jl
      Driver for all the plots.  Calls PlotWaveforms()

      FIXME: 1) Has references to saveHelper() to deal with.

-------------------------------------------------------------------
