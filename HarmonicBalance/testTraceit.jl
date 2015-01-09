using pd

module blah
using pd
export callerOfTraceIt

function callerOfTraceIt( )

   traceit( "hi" )
end
end

using blah

callerOfTraceIt( )

enableTrace() 

callerOfTraceIt( )
