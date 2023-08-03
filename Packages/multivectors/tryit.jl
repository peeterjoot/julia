# import Pkg; Pkg.add("Multivectors")

using Multivectors;

import Multivectors:symmetricdot;
symmetricdot(A::T, B::U) where {T<:Blade, U<:Blade} = grade(A*B, abs(grade(A)-grade(B))) |> prune;

using LinearAlgebra;

# generate blades for euclidean 3D-space
@generate_basis("+++", true)

show_basis()

# enter e\_1[tab] to get subscribed element:
# enter \wedge[tab] to get wedge symbol
# enter \cdot[tab] to get dot-product symbol
# ? to enter help -- can then cut and paste a symbol, and find out how to type it.
# help?> ∙
# "∙" can be typed by \vysmblkcircle<tab>

## not reliable (e₁ is the type)
#b1t = e₁
#b2t = e₂
#b3t = e₃
#b1t ∧ b2t
#b2t ∧ b3t
#b3t ∧ b1t

#const b1,b2,b3 = basis_1blades(Main)
const b1,b2,b3 = 1.0.*(basis_1blades(Main))
#b1 = 1e₁
#b2 = 1e₂
#b3 = 1e₃

b1 ∧ b2
b2 ∧ b3
b3 ∧ b1

#A = b1 ∧ b2
A = b1 * b2
v = b1

# dot products:
rcontraction(A,v)
rcontraction(v,A)
lcontraction(A,v)
lcontraction(v,A)

# rcontraction is something hodge dual related.
#1e₁ ⋅ A
# 1e₂
# A ⋅ 1e₁
#0

#symmetricdot(A, v) |> prune
#symmetricdot(v, A) |> prune
symmetricdot(A, v)
symmetricdot(v, A)

#julia> symmetricdot(A, v)
#Multivector{Int64, 1}
#⟨-1e₂⟩₁
#
#julia> symmetricdot(v, A)
#Multivector{Int64, 1}
#⟨1e₂⟩₁

# help?> ∙
# "∙" can be typed by \vysmblkcircle<tab>
# \vysmblkcircle<tab>
v ∙ A

#julia> v ∙ A
#1e₂
