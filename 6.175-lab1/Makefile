compile:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions TestBench.bsv

mux: compile
	bsc -sim -e mkTbMux -bdir buildDir -info-dir buildDir -simdir buildDir -o simMux buildDir/*.ba

muxsimple: compile
	bsc -sim -e mkTbMuxSimple -bdir buildDir -info-dir buildDir -simdir buildDir -o simMuxSimple buildDir/*.ba

rca: compile
	bsc -sim -e mkTbRCA -bdir buildDir -info-dir buildDir -simdir buildDir -o simRca buildDir/*.ba

rcasimple: compile
	bsc -sim -e mkTbRCASimple -bdir buildDir -info-dir buildDir -simdir buildDir -o simRcaSimple buildDir/*.ba

csa: compile
	bsc -sim -e mkTbCSA -bdir buildDir -info-dir buildDir -simdir buildDir -o simCsa buildDir/*.ba

csasimple: compile
	bsc -sim -e mkTbCSASimple -bdir buildDir -info-dir buildDir -simdir buildDir -o simCsaSimple buildDir/*.ba

bs: compile
	bsc -sim -e mkTbBS -bdir buildDir -info-dir buildDir -simdir buildDir -o simBs buildDir/*.ba

all: mux muxsimple rca rcasimple csa csasimple bs

clean:
	rm -rf buildDir sim*

.PHONY: clean all add compile
.DEFAULT_GOAL := all
