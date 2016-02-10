# ps 1, (3).

z_nought = 75 ;
vswr = 2.33 ;
GHz = 1e9 ;
f = 3 * GHz ;
d = 9.7e-3 ;
c = 3e8 ;

# part b:
abs_gamma_L = (vswr - 1)/(vswr + 1) ;

@printf( "\\Abs{\\Gamma_\\L} = %0.4g\n", abs_gamma_L ) ;

# part c:
omega = 2 * pi * f ;
vphi = c ;
beta = omega/vphi ;

theta_L = 2 * beta * d ;

@printf( "\\Theta_\\L = %0.4g\n", theta_L ) ;

# part d

gamma_L = abs_gamma_L * exp( im * theta_L ) ;
z_L = z_nought * (1 + gamma_L)/(1 - gamma_L) ;

@printf( "\\Gamma_\\L = %0.4g + %0.4g j\n", real(gamma_L), imag(gamma_L) ) ;
@printf( "\\Z_\\L = %0.4g + %0.4g j\n", real(z_L), imag(z_L) ) ;
