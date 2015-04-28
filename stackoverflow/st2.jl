 # Pkg.add("PyPlot")
    using PyPlot ;

    theta = 0:0.02:1 * pi ;
    n = length(theta) ;

    U = cos( theta ).^2 ;
    V = zeros( size(U) ) ;

    for i = 1:n
       v = log10( U[i] ) ;
       if ( v < -50/10 )
          v = 0 ;
       else
          v = v/5 + 1 ;
       end

       V[i] = v ;
    end

    f1 = figure("p2Fig1",figsize=(10,10)) ; # Create a new figure
    ax1 = axes( polar="true" ) ; # Create a polar axis

    pl1 = plot( theta, V, linestyle="-", marker="None" ) ;

    dtheta = 30 ;
    ax1[:set_thetagrids]([0:dtheta:360-dtheta]) ;
    ax1[:set_theta_zero_location]("E") ;
    f1[:canvas][:draw]() ;
