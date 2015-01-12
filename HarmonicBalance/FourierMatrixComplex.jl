#=
   FourierMatrixComplex Function to determine the fourier matrix for the discrete
   fourier transform and its inverse.
   N is the number of Harmonics to be used

   This constructs a matrix F that relates vector of DFT Fourier coefficients, defined by the transform pair:

       x_k = \sum_{n = -N}^N X_k e^{j omega n t_k}                    (1)
       X_k = (1/(2 N + 1)) \sum_{n = -N}^N x_k e^{-j omega n t_k}     (2)
       t_k = T k/(2 N + 1)                                            (3)
       omega T = 2 pi                                                 (4)

   Vectors:
      x = [x_{-N} ; x_{1-N} ; ... ; x_{N-1} ; x_{N} ]                 (5)
      X = [X_{-N} ; X_{1-N} ; ... ; X_{N-1} ; X_{N} ]                 (6)

   are related by:

      x = F X                                                         (7)
      X = \bar{F} X / (2 N + 1),                                      (8)

   where \bar{F} is the complex conjugate of F.
=#
function FourierMatrixComplex( N )
   r = -N:N ;
   twoNplusOne = 2 * N + 1 ;

   # http://stackoverflow.com/a/20388887/189270
   # http://www.mathworks.com/help/matlab/ref/ndgrid.html (Example: Evaluate Function over gridded domain)
   [X1, X2] = ndgrid( r, r ) ;

   # visual verification of the method.  This part is just the index pairs multiplied:
   # X1.*X2

   F = exp( 1j * 2 * pi * X1.*X2 / twoNplusOne ) ;
end
