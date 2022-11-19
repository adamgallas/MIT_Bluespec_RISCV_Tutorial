compile:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions TestBench.bsv

fold: compile
	bsc -sim -e mkTbFftFoldedFunc -bdir buildDir -info-dir buildDir -simdir buildDir -o simFoldedFunc
	bsc -sim -e mkTbFftFoldedImpl -bdir buildDir -info-dir buildDir -simdir buildDir -o simFoldedImpl
	
inelastic: compile
	bsc -sim -e mkTbFftInelasticPipelineFunc -bdir buildDir -info-dir buildDir -simdir buildDir -o simInelasticFunc
	bsc -sim -e mkTbFftInelasticPipelineImpl -bdir buildDir -info-dir buildDir -simdir buildDir -o simInelasticImpl

elastic: compile
	bsc -sim -e mkTbFftElasticPipelineFunc -bdir buildDir -info-dir buildDir -simdir buildDir -o simElasticFunc
	bsc -sim -e mkTbFftElasticPipelineImpl -bdir buildDir -info-dir buildDir -simdir buildDir -o simElasticImpl

# sfol: compile
# 	bsc -sim -e mkTbFftSuperFoldedFunc -bdir buildDir -info-dir buildDir -simdir buildDir -o simSfolFunc

all: fold inelastic elastic sfol

clean:
	rm -rf buildDir sim*

.PHONY: clean all fold inelastic elastic sfol compile
.DEFAULT_GOAL := all
