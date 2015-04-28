    function wrong()
    
       alphas = [ 0.5, 1, 1.25, 2.0 ] ;
       theta = 0:0.02:1 * pi ;
       U = zeros( length(theta), 4 ) ;
    
       i = 1 ;
       j = 1 ;
       for a = alphas
          kd = pi * a ;
    
          for t = theta
             v = (cos( kd * cos( t ) ) - cos( kd ))/sin( t ) ;
    
             U[i, j] = v ;
    
             i = i + 1 ;
          end 
    
          j = j + 1 ;
       end 
    end
