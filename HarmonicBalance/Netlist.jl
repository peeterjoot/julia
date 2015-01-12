module Netlist

   # export RCL_Line_T, SourceLine_T, VSourceLine_T, DiodeLine_T, PowerLine_T, NetlistLines_T, parser ;
   export NodalAnalysis ;
   using pd ;
   using SparseUtil ;

   type RCL_Line_T
      typePrefix::Char
      lableText
      node1::Int
      node2::Int
      value::Float64
   end

   type SourceLine_T
      typePrefix::Char
      lableText
      node1::Int
      node2::Int
      isDC::Bool
      value::Float64
      omega::Float64
      phase::Float64
   end

   type VSourceLine_T
      typePrefix::Char
      lableText
      node1::Int
      node2::Int
      nc1::Int
      nc2::Int
      gain::Float64
      vt::Float64
      exponent::Float64
   end

   type DiodeLine_T
      typePrefix::Char
      lableText
      node1::Int
      node2::Int
      io::Float64
      vt::Float64
   end

   type PowerLine_T
      typePrefix::Char
      lableText
      node1::Int
      node2::Int
      io::Float64
      vt::Float64
      exponent::Float64
   end

   type NetlistLines_T
      resistor
      inductor
      capacitor

      current
      voltage

      amplifier
      diode
      power

      allNodes
      allFrequencies
      numberOfNonlinearGains
   end

   #=
     NETLIST SYNTAX:
   
     This function contains the raw parsing logic for a text file (netlist) that describes an
     electrical circuit made of resistors, independent current sources,
     independent voltage sources, voltage-controlled voltage sources, capacitors, and inductors.
    
     For the netlist, a syntax similar to that of the widely-adopted SPICE program is described below, supporting
     elements with the following specifications:
    
     - The syntax for specifying a resistor is a line of the form:
    
         Rlabel node1 node2 value
    
       where "value" is the resistance value.
    
     - The syntax for specifying a current source is lines of the form:
    
         Ilabel node1 node2 DC value
         Ilabel node1 node2 AC value freq [phase]
    
       and current flows from node1 to node2.
       Here value, a floating point number, is the amplitude of the current.
       A line with 'DC value' is equivalent to that of 'AC value 0'. The parameter
       freq is the frequency in Hertz of the input signal.
    
     - The syntax for specifying a voltage source connected between the nodes node+ and
       node- is one of:
    
         Vlabel node+ node- DC value
         Vlabel node+ node- AC value freq [phase]
    
       where node+ and node- identify, respectively, the node where the positive
       and "negative" terminal is connected to, and value is the amplitude
       of the voltage source (a floating point value).
       A line with 'DC value' is equivalent to that of 'AC value 0'. The parameter
       freq is the frequency in Hertz of the input signal.
    
     - The syntax for specifying a voltage-controlled voltage source,
       connected between the nodes node+ and node-, is:
    
         Elabel node+ node- nodectrl+ nodectrl- gain [Vt P]
    
       The controlling voltage is between the nodes nodectrl+ and nodectrl-,
       and the last argument is the source gain (a floating point number).
    
       This models:
    
         V_{node+} - V_{node-} = gain (( V_{nodectrl+} - V_{nodectrl-} )/Vt )^P.
    
       Defaults: Vt = 1, P = 1.  When P is not equal to 1, non-linear power-law elements are returned.
    
     - The syntax for specifying a capacitor is:
    
         Clabel node1 node2 val
    
       where label is an arbitrary label, node1 and node2 are integer circuit node numbers, and val is
       the capacitance (a floating point number).
    
     - The syntax for specifying an inductor is:
    
         Llabel node1 node2 val
    
       where label is an arbitrary label, node1 and node2 are integer circuit node numbers, and val
       is the inductance (a floating point number).
    
     - The syntax for specifying a diode modelled by I_d = I_0 ( e^{V/V_t} - 1 ) is:
    
         Dlabel node1 node2 I_0 V_T
    
       where V = V_node1 - V_node2, and the current flows from n1 to n2.
    
     - The syntax for specifying a power-law non-linear term modelled by I = I_0 (V/V_t)^alpha is:
    
         Plabel node1 node2 I_0 V_T alpha
    
       where V is defined as for a diode line above.
    

     Implemented: 
       - Comment lines, starting with *, as described in the following, are allowed:
         http://jjc.hydrus.net/jjc/technical/ee/documents/spicehowto.pdf
       - .end terminates the netlist (case insensitive)
       - Trailing comments (; and anything after that) as described in:
         https://www.csupomona.edu/~prnelson/courses/ece220/220-spice-notes.pdf
         are allowed.
       - blank lines are ignored (spice may not do that).

     Not implemented: 
       - The first line of netlist is a (title) comment unless it starts with
         one of the supported element prefixes ( R, L, C, I, V, E, D, P )
       - Spice files allowed the constants to be specified with k, m, M modifiers.
       - Checking to verify that there are no gaps in the node numbers.
       - Checking to verify that the netlist file will always include a 0 (ground) node.
       - Checking to verify that a lable isn't reused.
    
     INPUTS:
    
     - filename [string]:
    
         netlist source file to read.

     OUTPUTS:

     - NetlistLines_T object with the line info for everything that was read.
   =# 
   function parser( filename )

      traceit( "filename: $filename" ) ;

      fh = open( filename ) ;

      firstLineRead = false ;
      allNodes = Int[] ;
      allFrequencies = Float64[] ;

      linesInfo = NetlistLines_T( RCL_Line_T[], RCL_Line_T[], RCL_Line_T[],
                                 SourceLine_T[], SourceLine_T[],
                                 VSourceLine_T[], DiodeLine_T[], PowerLine_T[],
                                 Int[], Float64[], 0 ) ;

      # Rlabel node1 node2 value
      # Clabel node1 node2 val
      # Llabel node1 node2 val
      #
      re_RCL = r"^
      ([RCL])(\S+)\s+
      (\d+)\s+
      (\d+)\s+
      (\S+)\s*$"x ;

      # Ilabel node1 node2 DC value
      # Vlabel node+ node- DC value
      #
      re_dcIV = r"^
      ([IV])(\S+)\s+
      (\d+)\s+
      (\d+)\s+
      DC\s+
      (\S+)\s*$"x ;

      # Dlabel node1 node2 I_0 V_T
      re_diode = r"^
      (D)(\S+)\s+
      (\d+)\s+
      (\d+)\s+
      (\S+)\s+
      (\S+)\s*$"x ;

      # Plabel node1 node2 I_0 V_T alpha
      re_power = r"^
      (P)(\S+)\s+
      (\d+)\s+
      (\d+)\s+
      (\S+)\s+
      (\S+)\s+
      (\S+)\s*$"x ;

      # Ilabel node1 node2 AC value freq [phase]
      # Vlabel node+ node- AC value freq [phase]
      re_acIV = r"^
      ([IV])(\S+)\s+
      (\d+)\s+
      (\d+)\s+
      AC\s+
      (\S+)\s+          # value
      (\S+)\s*(.*)$"x ;    # freq[, phase]

      # Elabel node+ node- nodectrl+ nodectrl- gain [Vt P]
      re_e = r"^
      (E)(\S+)\s+
      (\d+)\s+          # n+
      (\d+)\s+          # n-
      (\d+)\s+          # nc+
      (\d+)\s+          # nc-
      (\S+)\s*          # gain
      (.*)$"x ;         # [Vt P]

      # two space separated sequences:
      re_two = r"^(\S+)\s+(\S+)\s*$" ;

      re_blank = r"^\s*$" ;

      re_end = r"^\s*\.end\s*$"i ;

      re_stripTrailingComments = r"^(.*?)\s*;.*$" ;

      lineNumber = 0 ;
      numberOfNonlinearGains = 0 ;

      for line in eachline( fh )
         lineNumber = lineNumber + 1 ;

         line = chomp( line ) ;

         #traceit( "$filename:$lineNumber: raw line: $line" ) ;

         if ( line[1] == '*' )
            continue ;
         end

         m = match( re_end, line ) ;
         if ( m != nothing )
            break ;
         end

         m = match( re_stripTrailingComments, line )
         if ( m != nothing )
            line = m.captures[1] ;
         end

         m = match( re_blank, line )
         if ( m != nothing )
            continue ;
         end

         traceit( "$filename:$lineNumber: filtered line: $line" ) ;

         m = match( re_RCL, line ) ;
         if ( m != nothing )
            firstLineRead = true ;

            c = m.captures ;

            nodes = int(c[3:4]) ;
            push!( allNodes, nodes... ) ;

            typePrefix = c[1] ;

            i = RCL_Line_T( char(typePrefix[1]), c[2], nodes..., float(c[5]) ) ;

            if ( i.typePrefix == 'R' )
               push!( linesInfo.resistor, i ) ;
            elseif ( i.typePrefix == 'C' )
               push!( linesInfo.capacitor, i ) ;
            else
               push!( linesInfo.inductor, i ) ;
            end

            continue ;
         end

         m = match( re_dcIV, line ) ;
         if ( m != nothing )
            firstLineRead = true ;

            c = m.captures ;

            nodes = int(c[3:4]) ;
            push!( allNodes, nodes... ) ;

            typePrefix = c[1] ;

            i = SourceLine_T( char(typePrefix[1]), c[2], nodes..., false, float(c[5]), 0.0, 0.0 ) ;

            if ( i.typePrefix == 'V' )
               push!( linesInfo.voltage, i ) ;
            else
               push!( linesInfo.current, i ) ;
            end

            push!( allFrequencies, 0.0 ) ;

            continue ;
         end

         m = match( re_acIV, line ) ;
         if ( m != nothing )
            firstLineRead = true ;

            c = m.captures ;
            
            phase = c[7] ;
            if ( phase == "" )
               phase = 0 ;
            else
               phase = float( phase ) ;
            end

            nodes = int(c[3:4]) ;
            push!( allNodes, nodes... ) ;

            typePrefix = c[1] ;

            value = float(c[5]) ;
            omega = 2 * pi * float(c[6]) ;

            i = SourceLine_T( char(typePrefix[1]), c[2], nodes..., true, float(c[5]), omega, phase ) ;

            if ( i.typePrefix == 'V' )
               push!( linesInfo.voltage, i ) ;
            else
               push!( linesInfo.current, i ) ;
            end

            push!( allFrequencies, omega ) ;

            continue ;
         end

         m = match( re_diode, line ) ;
         if ( m != nothing )
            firstLineRead = true ;

            c = m.captures ;

            nodes = int(c[3:4]) ;
            push!( allNodes, nodes... ) ;

            typePrefix = c[1] ;

            i = DiodeLine_T( char(typePrefix[1]), c[2], nodes..., float(c[5]), float(c[6]) ) ;

            push!( linesInfo.diode, i ) ;

            continue ;
         end

         m = match( re_power, line ) ;
         if ( m != nothing )
            firstLineRead = true ;

            c = m.captures ;

            nodes = int(c[3:4]) ;
            push!( allNodes, nodes... ) ;

            typePrefix = c[1] ;

            i = PowerLine_T( char(typePrefix[1]), c[2], nodes..., float(c[5]), float(c[6]), float(c[7]) ) ;

            push!( linesInfo.power, i ) ;

            continue ;
         end

         m = match( re_e, line ) ;
         if ( m != nothing )
            firstLineRead = true ;

            c = m.captures ;

            optNonlinear = c[8] ;

            if ( optNonlinear == "" )
               vt = 0.0 ;
               exponent = 1.0 ;
            else
               # depend on throw here for error checking (like the type conversions do)
               m = match( re_two, optNonlinear ) ;

               vt = float( m.captures[1] ) ; 
               exponent = float( m.captures[2] ) ; 

               numberOfNonlinearGains = numberOfNonlinearGains + 1 ;
            end

            nodes = int(c[3:6]) ;
            push!( allNodes, nodes... ) ;

            typePrefix = c[1] ;

            i = VSourceLine_T( char(typePrefix[1]), c[2], nodes..., float(c[7]), vt, exponent ) ;

            push!( linesInfo.amplifier, i ) ;

            continue ;
         end

         throw( "$filename:$lineNumber: error parsing line '$line'" ) ;
      end

      # FIXME: implement: (or enforce spice requirement for this field)
      # titleline (using firstLineRead)

      linesInfo.allNodes = sort( unique( allNodes ) ) ;
      linesInfo.allFrequencies = sort( unique( allFrequencies ) ) ;
      linesInfo.numberOfNonlinearGains = numberOfNonlinearGains ;

      close( fh ) ;

      # return:
      linesInfo
   end

   include( "NodalAnalysis.jl" ) ;
end
