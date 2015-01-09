#=
   Problem determination helper functions.
=#
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

          # http://stackoverflow.com/a/27857414/189270
          #debug:1: C:\Users\IBM_ADMIN\AppData\Local\Julia-0.3.4\bin\libjulia.dll:-1:jl_unprotect_stack: hi
          #debug:2: C:\Users\IBM_ADMIN\AppData\Local\Julia-0.3.4\bin\libjulia.dll:-1:jl_backtrace_from_here: hi
          #debug:3: C:\cygwin64\home\Peeter\julia\HarmonicBalance\pd.jl:42:traceit: hi
          #debug:4: C:\cygwin64\home\Peeter\julia\HarmonicBalance\testTraceit.jl:9:callerOfTraceIt: hi

          i = 0 
          foundTraceIt = false

          for frame in bt
             i = i + 1
             #li = Profile.lookup( uint( bt[1] ) )
             li = Profile.lookup( uint( frame ) )
             #LineInfo("rec_backtrace","/home/tim/src/julia-old/usr/bin/../lib/libjulia.so",-1,true,140293228378757)

             #          n = names( Profile.LineInfo )
             #5-element Array{Symbol,1}:
             # :func 
             # :file 
             # :line 
             # :fromC
             # :ip  
             #
             fromC = li.fromC

             if ( fromC )
                continue
             elseif ( !foundTraceIt ) 
                foundTraceIt = true
                continue
             else
                file = li.file
                line = li.line
                func = li.func

                r = r".*[/\\](.*)"

                m = match( r, file )

                if ( m != nothing )
                  file = m.captures[1]
                end 

                #println( "debug:$i: $file:$line:$func:$fromC: $msg" )
                println( "debug: $file:$line:$func: $msg" )

                break
             end
          end
      end
   end
end
