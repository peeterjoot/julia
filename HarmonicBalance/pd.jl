module pd

   global g_bTraceOn = false 

   export enableTrace, disableTrace, traceit

   #=
     enable or disable trace
   =#
   function changeTrace( v )
      global g_bTraceOn

      g_bTraceOn = v
   end

   #=
    disable debug tracing.
       Sets a global trace variable to zero so that calls to traceit( ... ) don't print anything.
   =#
   function disableTrace( )
      changeTrace( false )
   end

   #=
    enable debug tracing.
       Sets a global trace variable to one so that calls to traceit( ... ) prints stuff.
   =#
   function enableTrace( )
      changeTrace( true )
   end

   #=
    trace a string

      if enableTrace() has been called, and disableTrace() has not, then the value of the string will be printed
      following a 'debug: ' prefix.
   =#
   function traceit( msg )
      global g_bTraceOn

      if ( g_bTraceOn )
          bt = backtrace()
          s = sprint(io->Base.show_backtrace(io, bt))

          println( "debug: $s: $msg" )
      end
   end
end
