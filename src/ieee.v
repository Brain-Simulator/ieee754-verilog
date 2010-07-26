//////////////////////////////////////////////////
//
// Perform A + B = C
// in single float precision
//
//////////////////////////////////////////////////

`define TOTALBITS 32 //number of bits in representation of a number
`define SIGN_LEN 1 //sign of a number needs 1 bit
`define EXPO_LEN 8 //length of exponent part
`define SIGNIFICAND_LEN `TOTALBITS - `SIGN_LEN - `EXPO_LEN // mantissa or significand of a number
`define GUARDBITS 3 //additional bits added to make addition/subtraction more precise

`define LASTBIT `TOTALBITS - 1
`define FIRSTBIT 0
`define EXPO_LASTBIT `LASTBIT - `SIGN_LEN
`define EXPO_FIRSTBIT `EXPO_LASTBIT - `EXPO_LEN + 1
`define SIGNIFICAND_LASTBIT `SIGNIFICAND_LEN - 1
`define SIGNIFICAND_FIRSTBIT 0

//
// Options
//
//use `undef or `define to change options
`undef REG_S1_TO_S2

///////////////////////////////////////////////
// MODULE: ieee_adder_prepare_input
///////////////////////////////////////////////
//
// Take input and convert it to suitable format.
//
////////////////////////////////////////////////

module ieee_adder_prepare_input(
	add_sub_bit,
	number,
	sign,
	exponent,
	significand
);
	//Two inputs and control bit
	// add_sub_bit=0 -> addition
	// add_sub_bit=1 -> subtraction
	input add_sub_bit;
	input [`LASTBIT:`FIRSTBIT] number;
	
	//Sign of numbers
	output sign;
	
	assign sign = number[`LASTBIT] ^ add_sub_bit;
	
	//Exponents
	output [`EXPO_LEN-1:0] exponent;
	
	assign exponent = number[`EXPO_LASTBIT:`EXPO_FIRSTBIT];
	
	//Nonzero exponent
	wire nonzero_exp;
	
	assign nonzero_exp = | exponent;
	
	//Significands with added bit 1 in front, and three guard bits,
	//in case that exponent is zero, we add 0 in front instead.
	output [`SIGNIFICAND_LEN:-`GUARDBITS] significand;
	
	assign significand = {nonzero_exp, number[`SIGNIFICAND_LASTBIT:`SIGNIFICAND_FIRSTBIT], `GUARDBITS'b0};
	
endmodule

////////////////////////////////////////////////////
// MODULE: ieee_adder_compare
////////////////////////////////////////////////////
//
// Compare exponents and significands between inputs
//
////////////////////////////////////////////////////

module ieee_adder_compare(
	exponentA,
	exponentB,
	significandA,
	significandB,
	expA_bigger_expB,
	inputA_bigger_inputB,
	shift_amount
);

	input [`EXPO_LEN-1:0] exponentA;
	input [`EXPO_LEN-1:0] exponentB;
	input [`SIGNIFICAND_LEN:-`GUARDBITS] significandA;
	input [`SIGNIFICAND_LEN:-`GUARDBITS] significandB;
	
	//How much to shift?
	output [`EXPO_LEN-1:0] shift_amount;
	//Borrow from subtraction.
	wire sub_borrow;
	
	assign {sub_borrow, shift_amount} = exponentA - exponentB;
	
	//Which exponent is bigger?
	output expA_bigger_expB;
	
	assign expA_bigger_expB = !sub_borrow;
	
	//Are exponents equal?
	//wire expA_equal_expB;
	
	//assign expA_equal_expB = ~& shift_amount;
	
	//Which input number is bigger?
	output inputA_bigger_inputB;
	
	//assign inputA_bigger_inputB = expA_equal_expB ? significandA > significandB :  expA_bigger_expB;
	
	//alternative option:
	assign inputA_bigger_inputB = {exponentA,significandA} > {exponentB,significandB};
endmodule

///////////////////////////////
// MODULE: ieee_adder_step1
///////////////////////////////
//
// Connect all stages together
//
///////////////////////////////

module ieee_adder_step1(
	clock_in,
	add_sub_bit,
	inputA,
	inputB,
	outputC);
	
	//Input clock
	input clock_in;
	
	//Two input numbers and output number in ieee format
	input add_sub_bit;
	input [`LASTBIT:`FIRSTBIT] inputA;
	input [`LASTBIT:`FIRSTBIT] inputB;
	output [`LASTBIT:`FIRSTBIT] outputC;
	
	//These are outputs of Stage 1
	wire signA;
	wire signB;
	wire [`EXPO_LEN-1:0] exponentA;
	wire [`EXPO_LEN-1:0] exponentB;
	wire [`SIGNIFICAND_LEN:-`GUARDBITS] significandA;
	wire [`SIGNIFICAND_LEN:-`GUARDBITS] significandB;
	
	//Call Stage 1
	ieee_adder_prepare_input S1_PREP_A(
		.add_sub_bit(1'b0),//A has + in front
		.number(inputA),
		.sign(signA),
		.exponent(exponentA),
		.significand(significandA)
	);
	ieee_adder_prepare_input S1_PREP_B(
		.add_sub_bit(add_sub_bit),//B might have a - sign in front
		.number(inputB),
		.sign(signB),
		.exponent(exponentB),
		.significand(significandB)
	);
	
	//Connect Stage 1 with Stage 2
	`ifdef REG_S1_TO_S2
		reg s1_signA;
		reg s1_signB;
		reg [`EXPO_LEN-1:0] s1_exponentA;
		reg [`EXPO_LEN-1:0] s1_exponentB;
		reg [`SIGNIFICAND_LEN:-`GUARDBITS] s1_significandA;
		reg [`SIGNIFICAND_LEN:-`GUARDBITS] s1_significandB;
	
		always@(posedge clock_in)
		begin
			s1_signA <= signA;
			s1_signB <= signB;
			s1_exponentA <= exponentA;
			s1_exponentB <= s1_exponentB;
			s1_significandA <= s1_significandA;
			s1_significandB <= s1_significandB;
		end
	`else
		wire s1_signA;
		wire s1_signB;
		wire [`EXPO_LEN-1:0] s1_exponentA;
		wire [`EXPO_LEN-1:0] s1_exponentB;
		wire [`SIGNIFICAND_LEN:-`GUARDBITS] s1_significandA;
		wire [`SIGNIFICAND_LEN:-`GUARDBITS] s1_significandB;
		assign s1_signA = signA;
		assign s1_signB = signB;
		assign s1_exponentA = exponentA;
		assign s1_exponentB = exponentB;
		assign s1_significandA = significandA;
		assign s1_significandB = significandB;
	`endif
	
	//These are outputs of Stage 2
	wire expA_bigger_expB;
	wire inputA_bigger_inputB;
	wire [`EXPO_LEN-1:0] shift_amount;
	
	//Call the stage 2
	ieee_adder_compare S2_COMP_AB(
		.exponentA(s1_exponentA),
		.exponentB(s1_exponentB),
		.significandA(s1_significandA),
		.significandB(s1_significandB),
		.expA_bigger_expB(expA_bigger_expB),
		.inputA_bigger_inputB(inputA_bigger_inputB),
		.shift_amount(shift_amount)
	);
	
	//Store shifted significands, significand with smaller exponent will be shifted to the right
	wire [`SIGNIFICAND_LEN:-`GUARDBITS] significandA2;
	wire [`SIGNIFICAND_LEN:-`GUARDBITS] significandB2;
	
	assign significandA2 = expA_bigger_expB ? significandA : significandA >> -shift_amount;
	assign significandB2 = expA_bigger_expB ? significandB >> shift_amount : significandB;
	
	//Performance note:
	// previous two operations can be done in parallel
	
	//Add two significands and store the carry of addition
	wire [`SIGNIFICAND_LEN:-`GUARDBITS] out_significand1;
	wire carry_significand;
	
	assign {carry_significand, out_significand1} = significandA2 + significandB2;
	
	//Store output exponent, this is simply the biggest out of two exponents
	wire [`EXPO_LEN-1:0] out_exponent1;
	
	assign out_exponent1 = expA_bigger_expB ? exponentA : exponentB;
	
	//In case that there was a significand overflow, exponent1 will be incremented by one,
	wire [`EXPO_LEN-1:0] out_exponent2;
	wire exponent_overflow;
	
	assign {exponent_overflow, out_exponent2} = 
		carry_significand ? 1 + out_exponent1
		: {1'b0, out_exponent1};
	
	/* 
	 * FUNCTION: normalize significand
	 * 
	 * Given the significand, we try to normalize it.
	 * It will not be needed if we need only addition.
	 * In case of subtraction it would be needed to normalize this thing!
	 */
	/*function [24:-3] normalize_significand;
		input [24:-3] significand;
		begin
			casex(significand)
				27'b1xxxxxxxxxxxxxxxxxxxxxxxxxx : normalize_significand = significand;
				//this is already normalized
				default: normalize_significand = {28{1'b0}};
			endcase
		end
	endfunction
	
	wire [24:-3] signf_normal;
	
	assign signf_normal = normalize_significand(out_significand1);*/
	
	//Construct output
	// in case there was significand overflow implies bit '1' in front.
	assign outputC = carry_significand ? 
		  {signA, out_exponent2, out_significand1[`SIGNIFICAND_LEN  :1]}
		: {signA, out_exponent2, out_significand1[`SIGNIFICAND_LEN-1:0]};
	
endmodule

