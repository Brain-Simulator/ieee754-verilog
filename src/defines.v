
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

`define `TYPE_NUMBER [`LASTBIT:`FIRSTBIT]
`define `TYPE_SIGNIF [`SIGNIFICAND_LEN:-`GUARDBITS]
`define `TYPE_EXPO   [`EXPO_LEN-1:0]
