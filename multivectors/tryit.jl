# import Pkg; Pkg.add("Multivectors")

using Multivectors;

@generate_basis("+++", true)  # generate blades for euclidean 3D-space

show_basis()

# enter e\_1[tab] to get subscribed element:
# enter \wedge[tab] to get wedge symbol

## not reliable (e₁ is the type)
#e1t = e₁
#e2t = e₂
#e3t = e₃
#e1t ∧ e2t
#e2t ∧ e3t
#e3t ∧ e1t

e1 = 1e₁
e2 = 1e₂
e3 = 1e₃

e1 ∧ e2
e2 ∧ e3
e3 ∧ e1

