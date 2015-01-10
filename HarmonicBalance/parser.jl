module Netlist
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
   freq::Float64
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
end

export RCL_Line_T,SourceLine_T,VSourceLine_T,DiodeLine_T,PowerLine_T,NetlistLines_T,parser ;

function parser( filename )

   fh = open( filename ) ;

   firstLineRead = false ;
   allNodes = Int[] ;

   lineInfo = NetlistLines_T( RCL_Line_T[], RCL_Line_T[], RCL_Line_T[],
                              SourceLine_T[], SourceLine_T[],
                              VSourceLine_T[], DiodeLine_T[], PowerLine_T[],
                              Int[] ) ;

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

   re_blankOrComment = r"(^\s*$)|(^\*)" ;

   for line in eachline( fh )
      line = chomp( line ) ;

      if ( line[1] == "*" )
         continue ;
      end

      if ( line[1] == ".end" )
         break ;
      end

      m = match( re_RCL, line ) ;
      if ( m != nothing )
         firstLineRead = true ;

         c = m.captures ;

         nodes = int(c[3:4]) ;
         push!(allNodes, nodes...) ;

         typePrefix = c[1] ;

         i = RCL_Line_T( char(typePrefix[1]), c[2], nodes..., float(c[5]) ) ;

         if ( i.typePrefix == 'R' )
            push!(lineInfo.resistor, i ) ;
         elseif ( i.typePrefix == 'C' )
            push!(lineInfo.capacitor, i ) ;
         else
            push!(lineInfo.inductor, i ) ;
         end

         continue ;
      end

      m = match( re_dcIV, line ) ;
      if ( m != nothing )
         firstLineRead = true ;

         c = m.captures ;

         nodes = int(c[3:4]) ;
         push!(allNodes, nodes...) ;

         typePrefix = c[1] ;

         i = SourceLine_T( char(typePrefix[1]), c[2], nodes..., false, float(c[5]), 0.0, 0.0 ) ;

         if ( i.typePrefix == 'V' )
            push!(lineInfo.voltage, i ) ;
         else
            push!(lineInfo.current, i ) ;
         end

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
         push!(allNodes, nodes...) ;

         typePrefix = c[1] ;

         i = SourceLine_T( char(typePrefix[1]), c[2], nodes..., true, float(c[5]), float(c[6]), phase ) ;

         if ( i.typePrefix == 'V' )
            push!(lineInfo.voltage, i ) ;
         else
            push!(lineInfo.current, i ) ;
         end

         continue ;
      end

      m = match( re_diode, line ) ;
      if ( m != nothing )
         firstLineRead = true ;

         c = m.captures ;

         nodes = int(c[3:4]) ;
         push!(allNodes, nodes...) ;

         typePrefix = c[1] ;

         i = DiodeLine_T( char(typePrefix[1]), c[2], nodes..., float(c[5]), float(c[6]) ) ;

         push!(lineInfo.diode, i ) ;

         continue ;
      end

      m = match( re_power, line ) ;
      if ( m != nothing )
         firstLineRead = true ;

         c = m.captures ;

         nodes = int(c[3:4]) ;
         push!(allNodes, nodes...) ;

         typePrefix = c[1] ;

         i = PowerLine_T( char(typePrefix[1]), c[2], nodes..., float(c[5]), float(c[6]), float(c[7]) ) ;

         push!(lineInfo.power, i ) ;

         continue ;
      end

      m = match( re_e, line ) ;
      if ( m != nothing )
         firstLineRead = true ;

         c = m.captures ;

         optNonlinear = c[8] ;

         if ( optNonlinear == "" )
            vt = 0.0 ;
            exponent = 0.0 ;
         else
            # depend on throw here for error checking (like the type conversions do)
            m = match( re_two, optNonlinear ) ;

            vt = float( m.captures[1] ) ; 
            exponent = float( m.captures[2] ) ; 
         end

         nodes = int(c[3:6]) ;
         push!(allNodes, nodes...) ;

         typePrefix = c[1] ;

         i = VSourceLine_T( char(typePrefix[1]), c[2], nodes..., float(c[7]), vt, exponent ) ;

         push!(lineInfo.amplifier, i ) ;

         continue ;
      end
   end

   lineInfo.allNodes = unique( allNodes ) ;

   close( fh ) ;

   lineInfo
end
end
