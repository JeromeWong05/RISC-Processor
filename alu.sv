


module ALU(Ain,Bin,ALUop,out,Z,V,N);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output reg [15:0] out;
    output reg Z, V, N;
    
    always_comb
    begin
        case(ALUop)
        2'b00: out = Ain + Bin; 
        2'b01: out = Ain - Bin; 
        2'b10: out = Ain & Bin; 
        2'b11: out = ~Bin;
        endcase

        //check if it is the zero flag
        if (out == 16'b0)
            Z = 1; 
        else Z = 0; 

        //check if it is the negative flag
        if (out[15] == 1'b1)
            N = 1; 
        else N = 0; 

        //check if it is the overflow flag
        if (ALUop == 2'b00)
        begin
            if (Ain[15] == 0 && Bin[15] == 0)
            begin
                if (out[15] == 0)
                    V = 0; 
                else V = 1; 
            end
            else if (Ain[15] == 1 && Bin[15] == 1)
            begin
                if (out[15] == 1)
                    V = 0; 
                else V = 1; 
            end
            else V = 0; 
        end
        else if (ALUop == 2'b01)
        begin
            if (Ain[15] == 1 && Bin[15] == 0)
            begin
                if (out[15] == 1)
                    V = 0; 
                else V = 1; 
            end
            else if (Ain[15] == 0 && Bin[15] == 1)
            begin
                if (out[15] == 0)
                    V = 0; 
                else V = 1; 
            end
            else V = 0; 
        end
        else V = 0; 



    end

endmodule