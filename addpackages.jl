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

# these are mine:
#Pkg.add("Netlist")
#Pkg.add("SparseUtil")
