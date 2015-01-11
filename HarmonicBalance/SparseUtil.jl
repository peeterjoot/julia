module SparseUtil

   import Base.spzeros

   export spzerosT
   #export spzerosComplexFloat

   #=
      Implement something like the matlab spzeros(..., 'like, T ) sort of syntax.
   =# 
   function spzerosT( m, n, T )

      #spzeros( eltype(T), Int, m, n ) ;
      spzeros( eltype(T), m, n ) ;
   end

#   function spzerosComplexFloat( m, n )
#
#      spzeros( Complex{Float64}, Int64, m, n ) ;
#   end
end
