#/bin/sh
#
# Used on windows together with:
# * msysgit  - http://code.google.com/p/msysgit/
# * iverilog - http://bleyer.org/icarus/
# * python   - http://www.python.org/
#

export PATH=$PATH:/x/verilog/iverilog/bin:/c/python27/

python /x/VerilogScript/VerilogScript.py src/ieee.vs || exit

cd src
python generate.py || exit
cd ..

rm src/ieee.v

echo 'Compiling verilog'
rm -f bin/single.out
python /x/VerilogScript/VerilogScript.py src/ieee.vs src/ieee_adder.v test/testbench.v -e "iverilog -o bin/single.out" || exit

echo 'Running simulation'
rm -f bin/simulation.out
vvp bin/single.out | tee bin/simulation.out

echo 'Compiling test'
rm -f bin/test.exe
gcc test/test_simulation.c -o bin/test.exe || exit

echo 'Running test'
bin/test.exe < bin/simulation.out

