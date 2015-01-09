f = open( "r.txt" ) ;

r1 = r"^\s*(\d+)\s*$" ;
r2 = r"^\s*(\d+)\s+(\d+)\s*$" ;

# no general match operator bounds like in perl, but can use triple quoted:
# triple quoted
r4 = r""".*"(.*)".*""" ;

# x modifier like in perl to break up regex's:
r3 = r"^\s*
(\d+)\s+ # does this work?
(\d+)\s+
(\d+)\s*
$"x ;

for line in eachline( f )
   line = chomp( line ) ;

   m = match( r1, line ) ;

   if ( m != nothing )
      println( "one int: '$line'" ) ;
   else
      m = match( r2, line ) ;

      if ( m != nothing )
         println( "two ints: '$line'" ) ;
      else
         m = match( r3, line ) ;

         if ( m != nothing )
            println( "three ints: '$line'" ) ;
         else
            println( "not ints: '$line'" ) ;
         end
      end
   end

   if ( m != nothing )
      for i in m.captures
         print( "$i, " ) ;
      end
      println( "" ) ;
   end

   m = match( r4, line ) ;
   if ( m != nothing )
      for i in m.captures
         println( "quoted: $i" ) ;
      end
   end
end

close( f ) ;
