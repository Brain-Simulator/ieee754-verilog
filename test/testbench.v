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

always
begin
	#1 clk = ! clk;
end

ieee_adder ADDER(
	.clock_in(clk),
	.add_sub_bit(add_sub),
	.inputA(inputA),
	.inputB(inputB),
	.outputC(outputC)
);

initial
begin
  $dumpfile("bin/1.vcd");
  $dumpvars(0, ADDER);
  
  //start the simulation
  clk = 0;
  add_sub = 0; //addition
  
  {inputA,inputB} = 0;
  `define DELAY 6
  `define TEST1_OP(val1,val2)\
			#`DELAY {inputA,inputB} = {val1,val2}; \
			#`DELAY $display("TEST1 %b %b %b", inputA, inputB, outputC); \
  
  `define TEST1(val1,val2) \
			`TEST1_OP(val1,val2)\
			`TEST1_OP(val2,val1)\
			`TEST1_OP(val1, 1<<31 ^ val2)\
			`TEST1_OP(val2, 1<<31 ^ val1)\
			`TEST1_OP(1<<31 ^ val1, val2)\
			`TEST1_OP(1<<31 ^ val2, val1)\
			`TEST1_OP(1<<31 ^ val1, 1<<31 ^ val2)\
			`TEST1_OP(1<<31 ^ val2, 1<<31 ^ val1)
  if(1)//test all
  begin
  `TEST1(`CS1dot5,`CS0dot5)
  `TEST1(`CS1dot5,`CS1dot5)
  `TEST1(`CS0dot5,`CS0dot5)
  `TEST1(`CS1,`CS1)
  `TEST1(`CS2,`CS2)
  `TEST1(`CS1,`CS2)
  `TEST1(`CS3,`CS3)
  `TEST1(`CS1,`CS3)
  `TEST1(`CS4,`CS4)
  `TEST1(`CS3,`CS4)
  `TEST1(`CS2,`CS4)
  `TEST1(`CS4,`CS0dot5)
  `TEST1(`CS4,`CS1dot5)
  `TEST1(`CS5,`CS4)
  `TEST1(`CS5,`CS5)
  `TEST1(`CS0,`CS0)
  `TEST1(`CS1,`CS0)
  `TEST1(`CS6,`CS1)
  `TEST1(`CS6,`CS0dot5)
  `TEST1(`CS7,`CS6)
  `TEST1(`CS8,`CS8)
  `TEST1(`CS8,`CS7)
  `TEST1(`CS0dot5,`CS7dot5)
  `TEST1(`CS1dot5,`CS7dot5)
  `TEST1(`CS8,`CS0dot5)
  `TEST1(`CS8,`CS1dot5)
   end
   else
   begin
	//test one instance
	{inputA, inputB} = {32'b10000000110000000000000000000001,32'b00000000100000000000000000000000};
	#1 $display("TEST1 %b %b %b", inputA, inputB, outputC);
   end
   //$display("TEST1 %b %b %b", inputA, inputB, outputC);
  #`DELAY $finish;
end

endmodule

