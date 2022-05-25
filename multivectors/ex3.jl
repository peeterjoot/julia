using Multivectors;
using LinearAlgebra;

@generate_basis("+++", true)

show_basis()

const e1,e2,e3 = one.(basis_1blades(Main))

A = e1 ∧ e2
v = e1

lcontraction(v,A)
