#c = Union{SubString{UTF8String},Void}["V","1","1","2","1"] ;
c = Union(Nothing,SubString{UTF8String})["V","1","1","2","1"] ;

nodes = int(c[3:4]) ;
