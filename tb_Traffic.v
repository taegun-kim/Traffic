`timescale 1ns / 1ns
module tb_Traffic;
reg Clk;
reg Rst;
reg Push;

Traffic U0(Clk, Rst, Push,,,,);
always #10 Clk =~Clk;
initial
begin
   Clk = 1;
   Rst = 0;
   Push = 1;

   @(negedge Clk) Rst = 1;
   #105000      Push = 0;    #20 Push = 1;
end
endmodule   