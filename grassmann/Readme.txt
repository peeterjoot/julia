https://github.com/chakravala/Grassmann.jl/issues/84


Setup basis with:


using Grassmann; @basis S"+++"
(R^3)

and can successfully select grades from some geometric products:

julia> ((v12 + v23) * v2)(0)
0v

julia> ((v12 + v23) * v2)(1)
1v₁ + 0v₂ - 1v₃
but not others:

julia> (v12 * v1)(1)
ERROR: MethodError: no method matching (::Simplex{⟨+++⟩,1,v₂,Int64})(::Int64)
Closest candidates are:
Any(::SubManifold{V,1,Indices} where Indices) where V at /home/pjoot/.julia/packages/DirectSum/aSUXQ/src/operations.jl:247
Any(::Simplex{V,1,B,T} where T where B) where V at /home/pjoot/.julia/packages/DirectSum/aSUXQ/src/operations.jl:252
Any(::Chain{V,1,𝕂,253} where 253 where 𝕂) where V at /home/pjoot/.julia/packages/Grassmann/Tvf1n /src/forms.jl:253
...
Stacktrace:


Answer:

You can now get around this issue in Grassmann v0.8 by using grade(t, g) or grade(t, ::Val{g}) where g is selected grade,<Paste>
