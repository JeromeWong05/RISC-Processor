


module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output reg [15:0] sout;
    reg [15:0] tempout; 
    reg temp; 

    always_comb
    begin
        tempout = 16'b0; 
        temp = 1'b0; 
        case(shift)
        2'b00: sout = in; 
        2'b01: sout = in << 1; 
        2'b10: sout = in >> 1; 
        2'b11: begin
            temp = in[0];
            tempout = in >> 1; 
            tempout[15] = temp; 
            sout = tempout; 
        end
        endcase
    end




endmodule