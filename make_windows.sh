#/bin/sh
#
# Used on MS Windows together with:
#
# * msysgit       - http://code.google.com/p/msysgit/
# * iverilog      - http://bleyer.org/icarus/
# * python        - http://www.python.org/
# * verilogscript - http://github.com/emiraga/verilogscript
#

echo 'Configuring environment'
#export PATH=$PATH:/x/verilog/iverilog/bin:/c/python27/
export PATH=$PATH:/c/iverilog/bin/:/c/python27/
export VSCRIPT=../VerilogScript/VerilogScript.py

mkdir -p bin

echo 'Generating pipeline'
python $VSCRIPT src/ieee.vs || exit
cd src
python generate.py || exit
cd ..
rm src/ieee.v

echo 'Compiling verilog'
rm -f bin/single.out
python $VSCRIPT src/ieee.vs src/ieee_adder.v test/testbench.v -e "iverilog -Wall -o bin/single.out" || exit

echo 'Running simulation'
rm -f bin/simulation.out
vvp bin/single.out > bin/simulation.out

echo 'Compiling test code'
rm -f bin/test.exe
gcc test/test_simulation.c -o bin/test.exe || exit

echo 'Running test'
bin/test.exe < bin/simulation.out

echo 'Autogenerate tests'
cd test/autogenerated
python 1.py 1.hex
cd ../..

echo 'Compiling autogenerated test'
rm -f bin/single.out
iverilog -Wall -o bin/single.out src/ieee.v src/ieee_adder.v test/autogenerated/testbench.v

echo 'Running autogenerated simulation'
rm -f bin/simulation.out
vvp bin/single.out > bin/simulation.out

echo 'Running autogenerated test'
bin/test.exe < bin/simulation.out

