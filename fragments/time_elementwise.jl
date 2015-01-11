# compare methods: http://stackoverflow.com/a/27884583/189270

function m1( freq )
   fr = abs( freq ) ;

tic() ;
   firstNonZeroIndex = int( fr[1] < 1 ) + 1 ;
   frPlus = fr[ firstNonZeroIndex:end ] ;
t = toq() ;

   push!( fr, -frPlus... ) ;
   allfrequencies = sort( fr ) ;
   
   (t, allfrequencies) ;
end

function m2( freq )
   fr = abs( freq ) ;

tic() ;
   frPlus = filter( x -> x > 0, fr ) ;
t = toq() ;

   push!( fr, -frPlus... ) ;
   allfrequencies = sort( fr ) ;

   (t, allfrequencies) ;
end

function m3( freq )
   fr = abs( freq ) ;

tic() ;
   frPlus = fr[ fr .> 0 ] ;
t = toq() ;

   push!( fr, -frPlus... ) ;
   allfrequencies = sort( fr ) ;

   (t, allfrequencies) ;
end

function timeThem( f )
   t1 = 0.0 ;
   t2 = 0.0 ;
   t3 = 0.0 ;

   for i in 1:1000
      x = m1( f ) ;
      y = m2( f ) ;
      z = m3( f ) ;

      t1 = t1 + x[1] ;
      t2 = t2 + y[1] ;
      t3 = t3 + z[1] ;
   end   
   t1 = t1/1000 ;
   t2 = t2/1000 ;
   t3 = t3/1000 ;

   println( "$t1, $t2, $t3" ) ;
# 8.18736799999999e-6, 0.00020341229400000006, 0.00011171932499999995
end
