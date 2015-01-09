s = open( readall, "t_file.jl" ) ;

println( s ) ;


f = open( "t_file.jl" ) ;

#s = readline( f ) ;
#println( s )

for line in eachline( f )
   line = chomp( line ) ;

   println( line ) ;
end

close( f ) ;
