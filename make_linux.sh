#!/bin/sh

vcs -q ieee_single.v testbench.v -R | tee simulation.out
gcc test_simulation.c -o a.out
./a.out < simulation.out

