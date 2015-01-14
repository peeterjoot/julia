#=
   Calls a Harmonic Balance solution function to solve the
   circuit described in fileName using the Harmonic Balance method,
   truncating the harmonics to N multiples of fundamental.
   Data of interest is plotted using one of: plot, stem, or loglog.
   
   parameters are passed as a Dict parameter for flexibility, and various defaults are assumed if 
   unspecified:
  
   p[ :logPlot ]
      default 0   (loglog plot when 1)
   p[ :spectrum ]
      default 0.  (stem plot when 1).
   p[ :allowCaching ]
      default 1.  Set to zero to avoid caching intermediate state when experimenting with the solving algoritms.
   p[ :N ]
      default 50
   p[ :useBigF ]
      default 0
   p[ :nofigure ]
      default 0
   p[ :legends ]
      default {} (no legends)
   p[ :title ]
      default '' (no title)
   p[ :figName ]
      required when nofigure unspecified.  Used to construct the path to save the plot in.
   p[ :figNum ]
      required when nofigure unspecified.  Used to construct the path to save the plot in.
   p[ :figDesc ]
      default '' (additional text to add to the plot save name)
   p[ :xLabel ]
      default: no xlabel.
   p[ :yLabel ]
      default: no ylabel.
   p[ :nPlus ]
   p[ :nMinus ]
      Arrays of plus and minus nodes of interest for the plots.
  
   parameters passed directly to HBSolve():
      p[ :dispfrequency ]
      p[ :dlambda ]
      p[ :iterations ]
      p[ :JcondTol ]
      p[ :minStep ]
      p[ :verbose ]
=#
function PlotWaveforms( p )

   if ( !haskey( p, :logPlot ) )
      p[ :logPlot ] = 0 ;
   end

   if ( !haskey( p, :allowCaching ) )
      p[ :allowCaching ] = 1 ;
   end

   if ( !haskey( p, :N ) )
      p[ :N ] = 50 ; 
   end
   N = p[ :N ] ;

   if ( !haskey( p, :useBigF ) )
      p[ :useBigF ] = 0 ;
   end

   if ( p[ :useBigF ] )
      currentCalculationMethodString = :BigF ;
   else
      currentCalculationMethodString = :SmallF ;
   end

   if ( p[ :logPlot ] )
      solutionMethodString = :TimingAndError ;
   else
      solutionMethodString = :DirectSolution ;
   end

   if ( !haskey( p, :nofigure ) )
      p[ :nofigure ] = 0 ;
   end

   if ( !haskey( p, :figDesc ) )
      p[ :figDesc ] = '' ;
   end

   if ( !haskey( p, :figNum ) )
      p[ :figNum ] = 0 ;
   end

   if ( !p[ :nofigure ] )
      f = figure ;
   end

   cacheFile = sprintf( '%s_%s_%s_N%d.mat', p[ :figName ], solutionMethodString, currentCalculationMethodString, N ) ;
   traceit( "cacheFile: $cacheFile" ) ;

   println( "PlotWaveForms: $cacheFile, ", p[ :figDesc ], p[ :figNum ] ) ;

   if ( exist( cacheFile, 'file' ) && p[ :allowCaching ] )
      load( cacheFile ) ;
   else

      if ( p[ :logPlot ] )
         h = TestSolver( p ) ;

         save( cacheFile, 'h' ) ;
      else
         # Harmonic Balance Parameters
         h = HBSolve( N, p ) ;

         # explicitly name the vars to avoid saving input param 'p'
         save( cacheFile, 'N', 'h' ) ;
      end
   end

#p
   if ( !p[ :logPlot ] )

      v = h[ :v ] ;
      V = h[ :V ] ;
      R = h[ :R ] ;

      f0 = h[ :omega ]/( 2 * pi ) ;
      T = 1/f0 ;
      dt = T/( 2 * N + 1 ) ;
      k = -N:N ;
      t = dt*k ;

      # for Frequency Response
      fMHz = k*f0/1e6;

      numPlots = size( p[ :nPlus ], 2 ) ;
   end

   if ( haskey( p, :verbose ) )
      h[ :xnames ]
   end

   if ( !haskey( p, :spectrum ) )
      p[ :spectrum ] = 0 ;
   end
   if ( !haskey( p, :legends ) )
      p[ :legends ] = {} ;
   end
   if ( !haskey( p, :title ) )
      p[ :title ] = '' ;
   end
   if ( !haskey( p, :figDesc ) )
      p[ :figDesc ] = '' ;
   end

   if ( p[ :logPlot ] )

      loglog( h[ :Nvalues ], h[ :errorValues ], '-o', h[ :Nvalues ], h[ :ecputimeValues ], '-o', 'linewidth', 2 ) ;

      logN = log( h[ :Nvalues ].' ) ;
      logErr = log( h[ :errorValues ] ) ;
      logCpu = log( h[ :ecputimeValues ] ) ;

      #plot( logN, logErr, '-o', logN, logCpu, '-o', 'linewidth', 2 ) ;

      pCpu = polyfit( logN, logCpu, 1 ) ;
      bCpu = pCpu(2) ;
      mCpu = pCpu(1) 

      # hack: bridge recitifier has -Inf error for the last N?
      pErr = polyfit( logN(1:end-1), logErr(1:end-1), 1 ) ;
      bErr = pErr(2) ;
      mErr = pErr(1) 

   else
      for m in 1:numPlots
         hold on ;

         if ( p[ :spectrum ] )
            vd = abs( V( p[ :nPlus ](m):R:end ) ) ;

            stem( fMHz, vd, 'linewidth', 2 ) ;
         else
            if ( p[ :nPlus ](m) && p[ :nMinus ](m) )
               vd = real( v( p[ :nPlus ](m):R:end ) ) - real( v( p[ :nMinus ](m):R:end ) ) ;
            elseif ( p[ :nPlus ](m) )
               vd = real( v( p[ :nPlus ](m):R:end ) ) ;
            else
               vd = -real( v( p[ :nMinus ](m):R:end ) ) ;
            end

            plot( t, vd, 'linewidth', 2 ) ;
         end
      end
   end
   if ( (size({}) != size( p[ :legends ] )) )
      legend( p[ :legends ], 'Location', 'SouthEast' ) ;
   end

   if ( haskey( p, :yLabel ) )
      xlabel( p[ :xLabel ] ) ;
   end

   if ( haskey( p, :yLabel ) )
      ylabel( p[ :yLabel ] ) ;
   end

   if ( !p[ :nofigure ] )
      # eliminate the background that makes the saved plot look
      # like the GUI display window background color:
      set( f, 'Color', 'w' ) ;

      hold off ;

      [fileExtension, savePlot] = saveHelper() ;

      saveName = sprintf( '%s%sFig%d.%s', p[ :figName ], p[ :figDesc ], p[ :figNum ], fileExtension ) ;

      savePlot( f, saveName ) ;
   end

   # show the title after saving the file
   if ( size( p[ :title ], 2 ) )
      title( p[ :title ] ) ;
   end
end
