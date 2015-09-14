push!(LOAD_PATH, pwd()) ; 

using Netlist ;

p = Dict{Symbol,Any}() ;
p[ :fileName ] = "../../matlab/ece1254/ps1/testdata/ps1.circuit.netlist" ;
r = NodalAnalysis( p[ :fileName ] ) ;

G = full(r[:G]) ;
b = full(r[:B]) ;

real(G\b)

# compares to results from phy1254.pdf
