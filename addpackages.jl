# include("addpackages.jl")
using Pkg

Pkg.add("IJulia") ;
Pkg.add("CPUTime") ;
Pkg.add("Cubature") ;
Pkg.add("Ipopt") ;
Pkg.add("NLopt") ;
Pkg.add("PyPlot") ;
Pkg.add("Gadfly") ;
Pkg.add("Cairo") ;
Pkg.add("Fontconfig") ;

package manager now has a mode in the repl.  type:

]
add IJulia
add CPUTime
add Ipopt
add NLopt
add PyPlot
add Gadfly
add Cubature -- failed.
add Cairo -- failed.
add Fontconfig -- failed.

control-C to exit package manager.

# these are mine:
#Pkg.add("Netlist")
#Pkg.add("SparseUtil")
