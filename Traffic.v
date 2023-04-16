module Traffic(i_Clk, i_Rst, i_Push, o_FND, o_LED, o_DM_Col, o_DM_Row);
input i_Clk;
input i_Rst;
input i_Push;
output wire [13:0] o_FND;
output wire [31:0] o_LED;
output wire [7:0] o_DM_Col, o_DM_Row;

reg [22:0] c_ClkCnt, n_ClkCnt;
reg [3:0] c_Sec0, n_Sec0;
reg [3:0] c_Sec1, n_Sec1;
reg [3:0] c_Sec2, n_Sec2;
reg c_Push, n_Push;
reg [2:0] c_State, n_State;
reg [31:0] c_LED, n_LED;
reg [63:0] c_Data, n_Data;

wire DM_o_fDone;
wire fLstClk;
wire fLstSec0, fLstSec1, fLstSec2;
wire fIncSec0, fIncSec1, fIncSec2;
wire fPush;
wire fTimesup, fTimeout;
wire fRchange, fYchange;
wire [12:0] fTime;
wire fBGO;

parameter LST_CLK = 100_000_000/20 -1;
parameter AGO = 3'h0;
parameter BGO = 3'h1;
parameter CGO = 3'h2;
parameter DGO = 3'h3;
parameter PUSH = 3'h4;
parameter YELLOW = 3'h5;
parameter  GO = {
8'b11111001,
8'b00111011,
8'b10111011,
8'b10000000,
8'b10000000,
8'b10111011,
8'b10011011,
8'b11110011};
parameter STOP = {
8'b11111111,
8'b11100011,
8'b00111011,
8'b10000000,
8'b10000000,
8'b00111011,
8'b11100011,
8'b11111111};


parameter AGREEN = 32'h0a808080;
parameter AYELLOW = 32'h20808080;
parameter BGREEN = 32'h800a8080;
parameter BYELLOW = 32'h80208080;
parameter CGREEN = 32'h80800a80;
parameter CYELLOW = 32'h80802080;
parameter DGREEN = 32'h8080800a;
parameter DYELLOW = 32'h80808020;
parameter ALLYELLOW = 32'h20202020;

FND FND0({c_Sec2, c_Sec1}, fBGO, o_FND);
DotMatrix DM0(i_Clk, i_Rst, c_Data, o_DM_Col, o_DM_Row, DM_o_fDone);

always@(posedge i_Clk, negedge i_Rst)
   if(!i_Rst) begin
      c_State = AGO;
      c_ClkCnt = 0;
      c_Sec0 = 0;
      c_Sec1 = 0;
      c_Sec2 = 3;
      c_Push = 1;
      c_LED = 32'h0a808080;
      c_Data = 0;
   end else begin
      c_State = n_State;
      c_ClkCnt = n_ClkCnt;
      c_Sec0 = n_Sec0;
      c_Sec1 = n_Sec1;
      c_Sec2 = n_Sec2;
      c_Push = n_Push;
      c_LED = n_LED;
      c_Data = n_Data;
   end

assign     fPush = !i_Push && c_Push;
assign     fLstClk = c_ClkCnt == LST_CLK,
   fLstSec0 = c_Sec0 == 0,
   fLstSec1 = c_Sec1 == 0,
   fLstSec2 = c_Sec2 == 0,
            fTimeout = (c_Sec0 == 1 && c_Sec1 == 0 && c_Sec2 == 0),
   fTimesup = (fTime <= 12'd32 && fTime >= 12'd2);
assign    fIncSec0 = fLstClk,
   fIncSec1 = fIncSec0 && fLstSec0,
   fIncSec2 = fIncSec1 && fLstSec1;
assign    o_LED = c_LED;
assign  fRchange = (fTimeout && fLstClk);
assign  fYchange = fTimesup;
assign  fTime = {c_Sec2, c_Sec1, c_Sec0};
assign  fPass = (fTime >= 12'd256);
assign  fBGO = (c_State == BGO && fPass);
 

always@*
begin
   n_State = c_State;
   n_ClkCnt = fLstClk ? 0 : c_ClkCnt + 1;
   n_Sec0 = fIncSec0 ? fLstSec0 ? 9 : c_Sec0 - 1 : c_Sec0;
   n_Sec1 = fIncSec1 ? fLstSec1 ? 9 : c_Sec1 - 1 : c_Sec1;
   n_Sec2 = fIncSec2 ? fLstSec2 ? 2 : c_Sec2 - 1 : c_Sec2;
   n_Push = c_Push;
   n_Data = fBGO ? GO : STOP;
   case(c_State)
      AGO: begin
        n_LED = fYchange ? AYELLOW : AGREEN;
        if(fRchange) n_State = BGO;
        if(fPush) n_State = PUSH;
      end
      BGO: begin
        n_LED = fYchange ? BYELLOW : BGREEN;
        if(fRchange) n_State = CGO;
        if(fPush) n_State = PUSH;
      end
      CGO: begin
        n_LED = fYchange ? CYELLOW : CGREEN;
        if(fRchange) n_State = DGO;
        if(fPush) n_State = PUSH;
      end
      DGO: begin
        n_LED = fYchange ? DYELLOW : DGREEN;
        if(fRchange) n_State = AGO;
        if(fPush) n_State = PUSH;
      end
      PUSH : begin
         n_LED = ALLYELLOW;
         n_ClkCnt = 0;
         n_Sec0 = 0;
         n_Sec1 = 2;
         n_Sec2 = 0;
         n_Push = 1;
         n_State = YELLOW;
         n_Data = GO;
      end
      YELLOW : begin
        if(fRchange) n_State = BGO;
    end
   endcase
end
endmodule