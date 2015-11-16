
# numerical values for rodbalancing.tex

function tGivenLM( L, M, g = 9.8, hbar = 10e-34 )

   t = hbar/(L * M * g)
   println( t )
end

tGivenLM(0.24, 0.01)
tGivenLM(0.24/12, 0.01/12/9)
tGivenLM(0.24/12, 0.01/12/16)
tGivenLM(0.24/12, 0.01/12/25)

# L=1mm, 1mg
tGivenLM(0.001, 1e-6)

# hair, width 58microns = 6e-5 m.  R=3e-5  m
# length 0.2mm = 2e-4 m (200 microns)
# density of hair:
# rho = 1.3 g/cm^3 = 1.3 e+3 kg/m^3
# M = rho pi (D/2)^2 L

function tGivenRhoDL( rho, d, L, g = 9.8, hbar = 10e-34 )

   t = hbar/(rho * pi * (d/2)^2 * L^2 * g) ;

   println( t )
end

tGivenRhoDL( 1300, 6e-5, 2e-4 ) 

