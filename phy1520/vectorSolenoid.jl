Pkg.add("PyPlot")
using PyPlot

rhoa = 0.25 ;

rho = collect(0:0.01:1) ;
a = zeros(size(rho)) ;

k=1
for r in rho
   if ( r < rhoa )
      a[k] = r/2 ;
   else
      a[k] = rhoa^2/r/2 ;
   end

   k = k + 1
end

#plot(rho, a, color="red", linewidth=2.0)
p = plot(rho, a, linewidth=2.0)

savefig( p, "vectorSolenoidFig1.pdf" )
savefig( p, "vectorSolenoidFig1.png" )
