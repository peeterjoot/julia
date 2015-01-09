    module pd

       global g_bTraceOn = true

       export callerOfTraceIt

       function callerOfTraceIt()
         traceit( "hi" ) ;
       end

       function traceit( msg )
          global g_bTraceOn

          if ( g_bTraceOn )
             bt = backtrace() ;
             s = sprint(io->Base.show_backtrace(io, bt))

             println( "debug: $s: $msg" )
          end
       end
    end

    using pd

    callerOfTraceIt( )
