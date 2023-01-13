#!/bin/bash

if [ -z $testResponse ]; then
    echo "What would you program would you like to run?"
    echo "1) asm tests"
    echo "2) small benchmarks"
    echo "3) big benchmarks"
    read testResponse
fi


case $testResponse in
    1) asm_tests=(
	         simple
	         add addi
	         and andi
	         auipc
	         beq bge bgeu blt bltu bne
	         j jal jalr
	         lw
	         lui
	         or ori
	         sw
	         sll slli
	         slt slti
	         sra srai
	         srl srli
	         sub
	         xor xori
	         bpred_bht bpred_j bpred_ras
	         cache
	     );
       vmh_dir=../programs/build/assembly/bin;;
    2) asm_tests=(
             towers
	         median
	         multiply
	         qsort
	         vvadd
	     ); vmh_dir=../programs/build/smallbenchmarks/bin;;
    3) asm_tests=(
	         median
	         multiply
	         qsort
	         vvadd
	     ); vmh_dir=../programs/build/bigbenchmarks/bin;;
    *)  echo "ERROR: Unexpected response: $response" ; exit ;;
esac

make -C ../programs/assembly -j8 
make -C ../programs/smallbenchmarks -j8
make -C ../programs/bigbenchmarks -j8

SOFTWARE_SOCKET_NAME=/tmp/connectal$USER
export SOFTWARE_SOCKET_NAME

log_dir=logs
wait_time=3

# create bsim log dir
mkdir -p ${log_dir}

pkill -u ${USER} bsim
pkill -u ${USER} ubuntu.exe
# run each test
for test_name in ${asm_tests[@]}; do
	echo "-- benchmark test: ${test_name} --"
	# copy vmh file
	mem_file=${vmh_dir}/${test_name}.riscv
	if [ ! -f $mem_file ]; then
		echo "ERROR: $mem_file does not exit, you need to first compile"
		exit
	fi
    ln -sf ${mem_file} program 

	# run test
    ./bluesim/bin/ubuntu.exe > ${log_dir}/${test_name}.log  # run bsim, redirect outputs to log
    sleep ${wait_time} # wait bsim to setup
done
pkill -u ${USER} bsim
pkill -u ${USER} ubuntu.exe
