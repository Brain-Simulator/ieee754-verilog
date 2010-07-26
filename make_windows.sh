#/bin/sh
#
# Used on windows together with:
# * msysgit  - http://code.google.com/p/msysgit/
# * iverilog - http://bleyer.org/icarus/
#

export PATH=$PATH:/x/verilog/iverilog/bin

echo 'Compiling verilog'
rm -f bin/single.out
iverilog src/ieee.v test/testbench.v -o bin/single.out || exit

echo 'Running simulation'
rm -f bin/simulation.out
vvp bin/single.out | tee bin/simulation.out

echo 'Compiling test'
rm -f bin/test.exe
gcc test/test_simulation.c -o bin/test.exe || exit

echo 'Running test'
bin/test.exe < bin/simulation.out

