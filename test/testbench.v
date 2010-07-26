//======================================================
//                    TEST BENCH
//======================================================
module main();

reg clk;
reg add_sub;
reg [31:0] inputA;
reg [31:0] inputB;
wire [31:0] outputC;

//define single precision constants
`define CS0 {1'b0, {31{1'b0}}}//0.0
`define CS0dot5 {1'b0, 8'b01111110, {23{1'b0}}}//0.5
`define CS1 {1'b0, 8'b01111111, {23{1'b0}}}//1.0
`define CS1dot5 {1'b0, 8'b01111111, 1'b1,{22{1'b0}}}//1.5
`define CS2 {1'b0, 8'b10000000, {23{1'b0}}}//2.0
`define CS3 {1'b0, 8'b10000000, 1'b1,{22{1'b0}}}//3.0
`define CS4 {1'b0, 8'b10000001, {23{1'b0}}}//4.0
`define CS5 {1'b0, 8'b10000001, 2'b01,{21{1'b0}}}//5.0
`define CS6 {1'b0, 8'b10000001, 1'b1,{22{1'b0}}}//6.0
`define CS7 {1'b0, 8'b10000001, 2'b11,{21{1'b0}}}//7.0
`define CS7dot5 {1'b0, 8'b10000001, 3'b111,{20{1'b0}}}//7.5
`define CS8 {1'b0, 8'b10000010, {23{1'b0}}}//8.0

initial
begin
  $dumpfile("bin/1.vcd");
  $dumpvars(0, STEP1);
  $monitor ("TEST %b %b %b", inputA, inputB, outputC);
  
  //start the simulation
  clk = 0;
  add_sub = 0;
  
  {inputA,inputB} = 0;
  `define DELAY 6
  #`DELAY {inputA,inputB} = {`CS1dot5,`CS0dot5};
  #`DELAY {inputA,inputB} = {`CS1dot5,`CS1dot5};
  #`DELAY {inputA,inputB} = {`CS0dot5,`CS0dot5};
  #`DELAY {inputA,inputB} = {`CS0dot5,`CS1dot5};
  #`DELAY {inputA,inputB} = {`CS1,`CS1};
  #`DELAY {inputA,inputB} = {`CS2,`CS2};
  #`DELAY {inputA,inputB} = {`CS2,`CS1};
  #`DELAY {inputA,inputB} = {`CS1,`CS2};
  #`DELAY {inputA,inputB} = {`CS3,`CS3};
  #`DELAY {inputA,inputB} = {`CS1,`CS3};
  #`DELAY {inputA,inputB} = {`CS3,`CS1};
  #`DELAY {inputA,inputB} = {`CS4,`CS4};
  #`DELAY {inputA,inputB} = {`CS4,`CS3};
  #`DELAY {inputA,inputB} = {`CS3,`CS4};
  #`DELAY {inputA,inputB} = {`CS4,`CS2};
  #`DELAY {inputA,inputB} = {`CS2,`CS4};
  #`DELAY {inputA,inputB} = {`CS4,`CS1dot5};
  #`DELAY {inputA,inputB} = {`CS1dot5,`CS4};
  #`DELAY {inputA,inputB} = {`CS4,`CS0dot5};
  #`DELAY {inputA,inputB} = {`CS0dot5,`CS4};
  #`DELAY {inputA,inputB} = {`CS5,`CS4};
  #`DELAY {inputA,inputB} = {`CS5,`CS5};
  #`DELAY {inputA,inputB} = {`CS0,`CS0};
  #`DELAY {inputA,inputB} = {`CS1,`CS0};
  #`DELAY {inputA,inputB} = {`CS0,`CS1};
  #`DELAY {inputA,inputB} = {`CS6,`CS1};
  #`DELAY {inputA,inputB} = {`CS1,`CS6};
  #`DELAY {inputA,inputB} = {`CS6,`CS0dot5};
  #`DELAY {inputA,inputB} = {`CS0dot5,`CS6};
  #`DELAY {inputA,inputB} = {`CS7,`CS6};
  #`DELAY {inputA,inputB} = {`CS8,`CS8};
  #`DELAY {inputA,inputB} = {`CS8,`CS7};
  #`DELAY {inputA,inputB} = {`CS0dot5,`CS7dot5};
  #`DELAY {inputA,inputB} = {`CS1dot5,`CS7dot5};
  
  #`DELAY $finish;
end

ieee_adder_step1 STEP1(
	.clock_in(clk),
	.add_sub_bit(add_sub),
	.inputA(inputA),
	.inputB(inputB),
	.outputC(outputC)
);

always
begin
	#1 clk = ! clk;
end

endmodule

