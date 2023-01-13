#include "util.h"

int main( int argc, char* argv[] ) {
	
	printStr("Benchmark permission\n");

	// we write mtohost and should fail since we are in user mode
	asm volatile ("csrw mtohost, x0");
	while(1);

	return 0;
}
	
