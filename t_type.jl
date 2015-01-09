type Foo
    a
    b::Int64
    c::Float64
end

type complex
    r::Float64
    i::Float64
end

f = Foo(1,2,3.0) ;
#Foo(1,2,3.0)

f.a
# 1

f.b
# 2

#f.c

