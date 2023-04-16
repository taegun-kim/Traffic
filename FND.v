module FND(i_Data, i_Ctrl, o_FND);
	
input	[7:0] i_Data;
input i_Ctrl;
output	reg	[13:0] o_FND;	// fnd data setting : g~a

wire [7:0] PassTime;

assign PassTime = i_Ctrl ? (i_Data - 8'h10) : 8'haa;

always@*
	case(PassTime[3:0])
		4'h0	: o_FND[6:0] = 7'b1000000;
		4'h1	: o_FND[6:0] = 7'b1111001;
		4'h2	: o_FND[6:0] = 7'b0100100;
		4'h3	: o_FND[6:0] = 7'b0110000;
		4'h4	: o_FND[6:0] = 7'b0011001;
		4'h5	: o_FND[6:0] = 7'b0010010;
		4'h6	: o_FND[6:0] = 7'b0000010;
		4'h7	: o_FND[6:0] = 7'b1011000;
		4'h8	: o_FND[6:0] = 7'b0000000;
		4'h9	: o_FND[6:0] = 7'b0011000;
		default	: o_FND[6:0] = 7'h7f;
	endcase
	
always@*
	case(PassTime[7:4])
		4'h0	: o_FND[13:7] = 7'b1111111;
		4'h1	: o_FND[13:7] = 7'b1111001;
		4'h2	: o_FND[13:7] = 7'b0100100;
		4'h3	: o_FND[13:7] = 7'b0110000;
		4'h4	: o_FND[13:7] = 7'b0011001;
		4'h5	: o_FND[13:7] = 7'b0010010;
		4'h6	: o_FND[13:7] = 7'b0000010;
		4'h7	: o_FND[13:7] = 7'b1011000;
		4'h8	: o_FND[13:7] = 7'b0000000;
		4'h9	: o_FND[13:7] = 7'b0011000;
		default	: o_FND[13:7] = 7'h7f;
	endcase	
	
endmodule
