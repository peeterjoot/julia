using Multivectors;
using LinearAlgebra;

@generate_basis("+++", true)

show_basis()

const e1,e2,e3 = basis_1blades(Main)

A = (1*e1) ∧ (1 *e2)
v = 1*e1

lcontraction(v,A)
