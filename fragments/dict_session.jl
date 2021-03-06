a = Dict()
#Dict{Any,Any} with 0 entries

b = ["one"=> 1, "two"=> 2, "three"=> 3]
#Dict{ASCIIString,Int64} with 3 entries:
#  "two"   => 2
#  "one"   => 1
#  "three" => 3

c = [:ONE=> 1.0, :TWO => 2, :BOOL=> true]
#Dict{Symbol,Any} with 3 entries:
#  :ONE  => 1.0
#  :BOOL => true
#  :TWO  => 2

c[:THREE] = 3.0
#3.0

c
#Dict{Symbol,Any} with 4 entries:
#  :ONE   => 1.0
#  :BOOL  => true
#  :THREE => 3.0
#  :TWO   => 2

keys(c)
#KeyIterator for a Dict{Symbol,Any} with 4 entries. Keys:
#  :ONE
#  :BOOL
#  :THREE
#  :TWO

for k in keys(c) ; println( k ) ; end
#ONE
#BOOL
#THREE
#TWO

haskey(c, "one")
#false

haskey(c, "ONE")
#false

haskey(c, :ONE)
#true

haskey(c, :blah)
#false

