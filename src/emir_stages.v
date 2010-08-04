/*
module emir_moduleZ(C,EA,EB,Z);
	input C;
	input EA;
	input EB;
	output Z;
endmodule

module emir_module2(input [0:2] D, output E);

endmodule

module emir_module1(A,B,C,D2,D1,Y);
	input A;
	input B;
	output C;
	output [0:2] D1;
	output [0:2] D2;
	output Y;
endmodule

*/
module emir_prep(A,B,C);
	input A;
	input B;
	output C;
endmodule

module emir_end(C,Z,Y);
	input C;
	output Y;
	output Z;
endmodule
