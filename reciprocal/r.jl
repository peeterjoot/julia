#=
   compute the unit normal of two three-vectors
=# 
function normal( a, b )

   n = cross( a, b ) ;

   a = norm(n) ;

   n/(a*a)
end

#=
   compute the reciprocals of two three-vectors
=# 
function reciprocals( a, b )

   n = normal( a, b ) ;

   ar = cross( b, n ) ;
   br = -cross( a, n ) ;

   (ar, br)
end

a = [1,1,0];
b = [1,0,-1];

(ar,br) = reciprocals(a,b);

#dot(ar,a)
#dot(br,b)
#dot(ar,b)
#dot(br,a)

# Should see the following for each of the computed reciprocal frames (i.e. they are also a basis for the manifold defined by span(a,b)).
# x = \sum_i (x \cdot x^i) x_i

dot(ar,ar) * a + dot(ar,br) * b - ar
dot(br,ar) * a + dot(br,br) * b - br
