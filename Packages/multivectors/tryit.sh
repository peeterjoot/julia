cat ${*-tryit.jl} | sed 's/#.*//' | grep -ve '^ *$' 
