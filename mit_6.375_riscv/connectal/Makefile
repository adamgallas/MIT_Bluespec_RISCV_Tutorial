CONNECTALDIR ?= /home/adam/connectal
BSVBASEDIR = $(abspath ..)/src
BASEDIR = $(abspath .)

S2H_INTERFACES = \
	ConnectalProcRequest:ConnectalWrapper.connectProc\
	ConnectalMemoryInitialization:ConnectalWrapper.initProc
H2S_INTERFACES = \
	ConnectalWrapper:ConnectalProcIndication:host

# FILES
CPPFILES = main.cpp Platform.cpp
BSVFILES = ConnectalWrapper.bsv Ifc.bsv
BSVDIR = $(BSVBASEDIR):$(BSVBASEDIR)/includes

export SOFTWARE_SOCKET_NAME=/tmp/connectal$(USER)

# Connectal Flags
CONNECTALFLAGS += -D $(VPROC) --bsvpath $(BSVDIR)
CONNECTALFLAGS += --bscflags " -D $(VPROC) -steps-max-intervals 50 +RTS -K256M -RTS"
CONNECTALFLAGS += --bscflags " -u -keep-fires -aggressive-conditions -show-schedule "
CONNECTALFLAGS += -D IMPORT_HOSTIF -D XILINX_SYS_CLK
CONNECTALFLAGS += --mainclockperiod 15

include $(CONNECTALDIR)/Makefile.connectal

.PHONY: simulation clean run_simulation
.DEFAULT_GOAL := simulation

run_simulation:
	ls ../programs/build/*/bin/*.riscv | xargs -I % sh -c "echo % && cp % ./program && bluesim/bin/ubuntu.exe"

simulation:
	rm -rf $(BASEDIR)/bluesim
	$(MAKE) build.bluesim

clean:
	rm -rf bluesim program
