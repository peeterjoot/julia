using Multivectors;
using LinearAlgebra;

@generate_basis("+++", true)

show_basis()

e1 = 1e₁
e2 = 1e₂
e3 = 1e₃

A = e1 ∧ e2
v = e1

lcontraction(v,A)
