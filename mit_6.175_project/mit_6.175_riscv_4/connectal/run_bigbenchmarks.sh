#!/bin/bash

# asm_tests=(
# 	median
# 	multiply
# 	qsort
# 	towers
# 	vvadd
# 	)

asm_tests=(
	median
	vvadd
	)

# asm_tests=(
# 	multiply
# 	#qsort
# 	)

vmh_dir=../programs/build/bigbenchmarks/bin
log_dir=logs
wait_time=120

# create bsim log dir
mkdir -p ${log_dir}

pkill bsim
pkill ubuntu.exe
# run each test
for test_name in ${asm_tests[@]}; do
	echo "-- benchmark test: ${test_name} --"
	# copy vmh file
	mem_file=${vmh_dir}/${test_name}.riscv
	if [ ! -f $mem_file ]; then
		echo "ERROR: $mem_file does not exit, you need to first compile"
		exit
	fi
	cp ${mem_file} bluesim/program 

	# run test
	make run.bluesim > ${log_dir}/${test_name}.log & # run bsim, redirect outputs to log
	sleep ${wait_time} # wait for bsim to setup
done
echo "big benchmark done"
pkill bsim
pkill ubuntu.exe
