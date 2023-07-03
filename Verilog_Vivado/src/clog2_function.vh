function [31:0] clog2;
   input [31:0] value;
   integer i;
   reg [31:0] j;
   begin
      j = value - 1;
      clog2 = 0;
      for (i = 0; i < 31; i = i + 1)
        if (j[i]) clog2 = i+1;
   end
endfunction