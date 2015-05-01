function foo( theta, U ; normalize = false, args... )

   if ( normalize )
      println("normalize") ;
   end

#julia> foo(1, 2 ; normalize = true, a = 1, b = [1, 2,3])
#normalize
#{(:a,1),(:b,[1,2,3])}
#println( args ) ;

   args = Dict(zip(args...)...) ;
   xx = args[ :a ] ;

   println( xx ) ;
#   println( args[ :c ] ) ;
   println( get( args, :c, 42 ) ) ;
end

#foo(1, 2 ; normalize = true, a = 1, c = 7 )
#foo(1, 2 ; normalize = true, a = 1 )

