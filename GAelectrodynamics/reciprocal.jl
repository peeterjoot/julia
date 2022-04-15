
# verify hand calculation in 2subspaceR3reciprocalExample.tex

x = [1,2,0];
y = [0,1,-1];

u = [1,1,1]/3;
v = [-2,1,-5]/6;

xu = x'u;
xv = x'v;
yu = y'u;
yv = y'v;

println( "x . u = $xu" );
println( "x . v = $xv" );
println( "y . u = $yu" );
println( "y . v = $yv" );
