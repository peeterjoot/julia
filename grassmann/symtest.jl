using Grassmann, SymPy, LinearAlgebra
@basis S"+++" E e

@vars a b c d

m = a * e1 + b * e12 + c * e123

println( m )

m = d * e + a * e1 + b * e12 + c * e123

println( m )
