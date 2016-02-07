# ps 1, (3).

z_nought = 75 ;
vswr = 2.33 ;
f = 3e9 ;
d = 9.7e-3 ;

# part b:
abs_gamma_L = (vswr - 1)/(vswr + 1) ;

println( "\\Abs{\\Gamma_\\L} = $abs_gamma_L" ) ;

# part c:
omega = 2 * pi * f ;
vphi = 3e9 ;
beta = omega/vphi ;

theta_L = 2 * beta * d ;

println( "\\Theta_\\L} = $theta_L" ) ;

# part d

gamma_L = abs_gamma_L * exp( im * theta_L ) ;
z_L = z_nought * (1 + gamma_L)/(1 - gamma_L) ;

println( "\\Gamma_\\L} = $gamma_L" ) ;
println( "\\Z_\\L = $z_L" ) ;
