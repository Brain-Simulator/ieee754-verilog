`include "src/defines.v"

module ieee_adder_prepare_input(
	input add_sub_bit,
	input `WIDTH_NUMBER number,
	output sign,
	output `WIDTH_EXPO exponent,
	output `WIDTH_SIGNIF signif):
	//Take input and convert it to suitable format.
	sign := number[`LASTBIT] ^ add_sub_bit
	exponent := number[`EXPO_LASTBIT:`EXPO_FIRSTBIT]
	//Add bit 1 in front in case that exponent is non-zero
	signif := {|exponent, number[`SIGNIF_LASTBIT:`SIGNIF_FIRSTBIT], `GUARDBITS'b0}

module ieee_adder_compare(
	input `WIDTH_EXPO exponentA,
	input `WIDTH_EXPO exponentB,
	input `WIDTH_SIGNIF signifA,
	input `WIDTH_SIGNIF signifB,
	output expA_bigger_expB,
	output inputA_bigger_inputB,
	output `WIDTH_EXPO shift_amount):
	// Compare exponents and significands between inputs
	wire sub_borrow
	{sub_borrow, shift_amount} := exponentA - exponentB
	expA_bigger_expB := !sub_borrow
	inputA_bigger_inputB := {exponentA, signifA} > {exponentB, signifB}

module ieee_adder_shift_signif(
	input expA_bigger_expB,
	input `WIDTH_SIGNIF signifA,
	input `WIDTH_SIGNIF signifB,
	input `WIDTH_EXPO shift_amount,
	output `WIDTH_SIGNIF signifA_shift_1,
	output `WIDTH_SIGNIF signifB_shift_1):
	//Store shifted significands, significand with smaller exponent will be shifted to the right
	signifA_shift_1 := expA_bigger_expB ? signifA : signifA >> -shift_amount
	signifB_shift_1 := expA_bigger_expB ? signifB >> shift_amount : signifB

module ieee_adder_swap_signif(
	input inputA_bigger_inputB,
	input `WIDTH_SIGNIF signifA_shift_1,
	input `WIDTH_SIGNIF signifB_shift_1,
	output `WIDTH_SIGNIF signifA_shift,
	output `WIDTH_SIGNIF signifB_shift):
	{signifA_shift,signifB_shift} := {
		inputA_bigger_inputB ?
			{signifA_shift_1, signifB_shift_1}
		:	{signifB_shift_1, signifA_shift_1}
	}

module ieee_adder_bigger_exp(
	input inputA_bigger_inputB,
	input `WIDTH_EXPO exponentA,
	input `WIDTH_EXPO exponentB,
	output `WIDTH_EXPO big_expo):
	big_expo := inputA_bigger_inputB ? exponentA : exponentB

module ieee_adder_opadd(
	input `WIDTH_SIGNIF signifA_shift,
	input `WIDTH_SIGNIF signifB_shift,
	input `WIDTH_EXPO big_expo,
	output `WIDTH_SIGNIF_PART out_signif_add,
	output `WIDTH_EXPO out_exponent_add):
	//Add two significands and store the carry of addition
	wire carry_signif
	wire `WIDTH_SIGNIF out_signif_add_1
	{carry_signif, out_signif_add_1} := signifA_shift + signifB_shift
	wire `WIDTH_EXPO out_exponent_add_1
	wire exponent_overflow_add
	{exponent_overflow_add, out_exponent_add_1} := carry_signif ? 1 + big_expo : {1'b0, big_expo}
	out_signif_add := carry_signif ? out_signif_add_1[`SIGNIF_LEN  :1] : out_signif_add_1[`SIGNIF_LEN-1:0]
	out_exponent_add := out_exponent_add_1

module ieee_adder_opsub(
	input `WIDTH_SIGNIF signifA_shift,
	input `WIDTH_SIGNIF signifB_shift,
	input `WIDTH_EXPO big_expo,
	output `WIDTH_SIGNIF out_signif_sub_1,
	output signif_nonzero):
	//Subtract two significands and store the borrow borrow_signif
	out_signif_sub_1 := signifA_shift - signifB_shift
	signif_nonzero := |(out_signif_sub_1)

module ieee_adder_normalize_sub(
	input `WIDTH_SIGNIF out_signif_sub_1,
	output `WIDTH_SIGNIF_PART out_signif_sub,
	input `WIDTH_EXPO big_expo,
	output `WIDTH_EXPO out_exponent_sub):
	function [4:0] normalize4:
		input `WIDTH_SIGNIF __number
		casex(__number):
			{ 0'b0,1'b1,26'bx}: normalize4 = 5'd0;
			{ 1'b0,1'b1,25'bx}: normalize4 = 5'd1;
			{ 2'b0,1'b1,24'bx}: normalize4 = 5'd2;
			{ 3'b0,1'b1,23'bx}: normalize4 = 5'd3;
			{ 4'b0,1'b1,22'bx}: normalize4 = 5'd4;
			{ 5'b0,1'b1,21'bx}: normalize4 = 5'd5;
			{ 6'b0,1'b1,20'bx}: normalize4 = 5'd6;
			{ 7'b0,1'b1,19'bx}: normalize4 = 5'd7;
			{ 8'b0,1'b1,18'bx}: normalize4 = 5'd8;
			{ 9'b0,1'b1,17'bx}: normalize4 = 5'd9;
			{10'b0,1'b1,16'bx}: normalize4 = 5'd10;
			{11'b0,1'b1,15'bx}: normalize4 = 5'd11;
			{12'b0,1'b1,14'bx}: normalize4 = 5'd12;
			{13'b0,1'b1,13'bx}: normalize4 = 5'd13;
			{14'b0,1'b1,12'bx}: normalize4 = 5'd14;
			{15'b0,1'b1,11'bx}: normalize4 = 5'd15;
			{16'b0,1'b1,10'bx}: normalize4 = 5'd16;
			{17'b0,1'b1, 9'bx}: normalize4 = 5'd17;
			{18'b0,1'b1, 8'bx}: normalize4 = 5'd18;
			{19'b0,1'b1, 7'bx}: normalize4 = 5'd19;
			default: normalize4 = 5'd31;
	wire [4:0] normal_shift
	normal_shift := normalize4(out_signif_sub_1)
	wire `WIDTH_SIGNIF out_signif_sub_2
	out_signif_sub_2 := out_signif_sub_1 << normal_shift
	out_exponent_sub := big_expo - normal_shift
	out_signif_sub := out_signif_sub_2[`SIGNIF_LEN-1:0]

module ieee_adder_final(
	input signA,
	input signB,
	input inputA_bigger_inputB,
	input `WIDTH_EXPO out_exponent_add,
	input `WIDTH_SIGNIF_PART out_signif_add,
	input `WIDTH_EXPO out_exponent_sub,
	input `WIDTH_SIGNIF_PART out_signif_sub,
	input signif_nonzero,
	input `WIDTH_EXPO shift_amount,
	output `WIDTH_NUMBER outputC):
	wire neg_op
	neg_op := signA ^ signB
	wire out_sign
	out_sign := inputA_bigger_inputB ? signA : signB
	wire nonequal = (|shift_amount) | signif_nonzero
	outputC := {
		neg_op ?
			{
				nonequal ?
				{out_sign, out_exponent_sub, out_signif_sub}
				:	`TOTALBITS'b0
			}
		:
		{out_sign, out_exponent_add, out_signif_add}
	}
