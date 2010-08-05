`include "src/defines.v"

module ieee_adder_prepare_input(
		input add_sub_bit,
		input `WIDTH_NUMBER number,
		output sign,
		output `WIDTH_EXPO exponent,
		output `WIDTH_SIGNIF significand):
	//Take input and convert it to suitable format.
	sign := number[`LASTBIT] ^ add_sub_bit
	exponent := number[`EXPO_LASTBIT:`EXPO_FIRSTBIT]
	//Add bit 1 in front in case that exponent is non-zero
	significand := {|exponent, number[`SIGNIF_LASTBIT:`SIGNIF_FIRSTBIT], `GUARDBITS'b0}

module ieee_adder_compare(
		input `WIDTH_EXPO exponentA,
		input `WIDTH_EXPO exponentB,
		input `WIDTH_SIGNIF significandA,
		input `WIDTH_SIGNIF significandB,
		output expA_bigger_expB,
		output inputA_bigger_inputB,
		output `WIDTH_EXPO shift_amount):
	// Compare exponents and significands between inputs
	wire sub_borrow
	{sub_borrow, shift_amount} := exponentA - exponentB
	expA_bigger_expB := !sub_borrow
	inputA_bigger_inputB := {exponentA,significandA} > {exponentB,significandB}

module ieee_adder_stage3(
		input `WIDTH_SIGNIF significandA,
		input `WIDTH_SIGNIF significandB,
		input `WIDTH_EXPO shift_amount,
		input `WIDTH_EXPO exponentA,
		input `WIDTH_EXPO exponentB,
		input expA_bigger_expB,
		output `WIDTH_NUMBER outputC):
	//Store shifted significands, significand with smaller exponent will be shifted to the right
	wire `WIDTH_SIGNIF significandA2
	significandA2 := expA_bigger_expB ? significandA : significandA >> -shift_amount
	wire `WIDTH_SIGNIF significandB2
	significandB2 := expA_bigger_expB ? significandB >> shift_amount : significandB
	//Add two significands and store the carry of addition
	wire `WIDTH_SIGNIF out_significand1
	wire carry_significand
	{carry_significand, out_significand1} := significandA2 + significandB2
	//Store output exponent, this is simply the biggest out of two exponents
	wire `WIDTH_EXPO out_exponent1
	out_exponent1 := expA_bigger_expB ? exponentA : exponentB
	//In case that there was a significand overflow, exponent1 will be incremented by one,
	wire `WIDTH_EXPO out_exponent2
	wire exponent_overflow
	{exponent_overflow, out_exponent2} := carry_significand ? 1 + out_exponent1 : {1'b0, out_exponent1}
	//Construct output, in case there was significand overflow implies bit '1' in front.
	outputC := {
		carry_significand ? 
		  {signA, out_exponent2, out_significand1[`SIGNIF_LEN  :1]}
		: {signA, out_exponent2, out_significand1[`SIGNIF_LEN-1:0]}
	}
