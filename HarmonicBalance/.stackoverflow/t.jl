    re_dcIV = r"^
    ([IV])(\S+)\s+
    (\d+)\s+
    (\d+)\s+
    DC\s+
    (\S+)\s*$"x ;
    
    line = "V1 1 2 DC 1" ;
    
    m = match( re_dcIV, line ) ;
    
    c = m.captures ;
    println( "$c\n" ) ;
    
    nodes = int(c[3:4]) ;
