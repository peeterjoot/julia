# This plots |1 - exp(2 j theta)|, the multisection quarter wavelength transformer.

# prereq:
#Pkg.add("PyPlot")

using PyPlot
# notes:
# http://stackoverflow.com/questions/22041461/julia-pyplot-from-script-not-interactive
# http://stackoverflow.com/questions/8213522/matplotlib-clearing-a-plot-when-to-use-cla-clf-or-close

theta = collect(0:0.01:pi)

function gamma(n)
   (exp(-2 * theta * im) .+ 1).^n
end

f1 = figure("deck7Fig1",figsize=(10,10)) ; # Create a new figure

nValues = [1,2,3,4]
for n in nValues
   plot( theta, abs(gamma(n)), linewidth=2.0 ) 
end
#plot( theta, abs(gamma(1)), linewidth=2.0 ) 
#plot( theta, abs(gamma(2)), linewidth=2.0 ) 
#plot( theta, abs(gamma(3)), linewidth=2.0 ) 
#plot( theta, abs(gamma(4)), linewidth=2.0 ) 

#ylabel(L"$\left\vert \Gamma \right\vert$")
# LatexStrings appears to have some limitations.  It can't seem to handle \vert, \lvert or \rvert?
#\lvert\Gamma\rvert
#^
#Unknown symbol: \lvert (at char 0), (line:1, col:1)
ylabel(L"$|\Gamma|$")

# http://nbviewer.jupyter.org/github/gizmaa/Julia_Examples/blob/master/pyplot_annotation.ipynb
ax = gca() ;
setp(ax[:get_yticklabels](),fontsize=16) ; # Y Axis font formatting
#setp(ax[:get_yticklabels](),fontsize=16,color="blue") ; # Y Axis font formatting

# http://stackoverflow.com/a/12921209/189270
xticks([0, pi/4, pi/2, 3*pi/4, pi],
       [L"$0$", L"$\frac{\pi}{4}$", L"$\frac{\pi}{2}$", L"$\frac{3\pi}{4}$", L"$\pi$"])
setp(ax[:get_xticklabels](),fontsize=18) ; # X Axis font formatting

PyPlot.legend(nValues, loc="lower right") ;

savefig("multitransformerFig1.pdf")
savefig("multitransformerFig1ng.png")
