#p[ :figName ] = "opAmp" ;
#p[ :figNum ] = 1 ;
##p[ :logPlot ] = true ;
#p[ :figDesc ] = "x" ;
#p[ :title ] = "x" ;
##p[ :legends ] = [ "Normalized Error", "CPU Time" ] ;
##p[ :xLabel ] = "N (Number of Harmonics)" ;

push!(LOAD_PATH, pwd()) ; 

using Netlist ;
#using CPUTime ;
p = Dict{Symbol,Any}() ;
p[ :fileName ] = "../../matlab/ece1254/ps1/testdata/ps1.circuit.netlist" ;
r = NodalAnalysis( p[ :fileName ] ) ;

#julia> full(r[:G])
#8x8 Array{Float64,2}:
#  0.0001    -0.0001        0.0      0.0        0.0     -1.0  0.0  0.0
# -0.0001     0.0001385    -2.5e-5  -1.25e-5    0.0      0.0  0.0  0.0
#  0.0       -2.5e-5        2.6e-5   0.0       -1.0e-6   0.0  1.0  0.0
#  0.0       -1.25e-5       0.0      6.25e-5   -5.0e-5   0.0  0.0  1.0
#  0.0        0.0          -1.0e-6  -5.0e-5     7.6e-5   0.0  0.0  0.0
#  1.0        0.0           0.0      0.0        0.0      0.0  0.0  0.0
#  0.0     -Inf            -1.0      0.0        0.0      0.0  0.0  0.0
#  0.0        0.0        -Inf       -1.0      Inf        0.0  0.0  0.0

# 1) last two rows, and first two columns are wrong.
# 2) also: xnames for i_{1,0} has a different sign than my report?
#    was that an error that I corrected along the way?

#include( "NodalAnalysis.jl" ) ;
#r = NodalAnalysis( "../../matlab/ece1254/ps1/testdata/ps1.circuit.netlist" ) ;

