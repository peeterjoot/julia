LOCALFILES += CPUTime.jl

all : $(LOCALFILES)

CPUTime.jl : ../CPUTime.jl/src/CPUTime.jl
	cp $^ $@

clean: 
	rm -f $(CLEAN) $(LOCALFILES)
