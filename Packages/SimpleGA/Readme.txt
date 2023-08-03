import Pkg;

# doesn't work:
#Pkg.add("SimpleGA")
#Pkg.add("GA20")
#Pkg.add(url="https://github.com/chrisjldoran/SimpleGA/blob/main/GA20.jl")

# also doesn't work: "could not find project file (Project.toml or JuliaProject.toml)"
Pkg.develop(path=ENV["HOME"] * "/julia/SimpleGA")

https://www.youtube.com/watch?v=imZE2k7gJ0Q 5:00

#using ...
