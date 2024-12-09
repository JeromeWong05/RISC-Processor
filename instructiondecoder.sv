

module instructiondecoder(in, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);

    //defining the inputs and outputs
    input [15:0] in; 
    input [1:0] nsel; 

    output [1:0] ALUop, shift, op; 
    output [15:0] sximm5, sximm8; 
    output [2:0] opcode;
    output reg [2:0] readnum, writenum; 

    //ALUop output
    assign ALUop = in[12:11];

    //sign extend sximm5
    assign sximm5 = (in[4] == 1'b1) ? {{11{1'b1}}, in[4:0]} : {{11{1'b0}}, in[4:0]};

    //sign extend sximm8
    assign sximm8 = (in[7] == 1'b1) ? {{8{1'b1}}, in[7:0]} : {{8{1'b0}}, in[7:0]};

    //shift output
    assign shift = in[4:3];

    //opcode and op
    assign opcode = in[15:13];
    assign op = in[12:11];

    //mux for readnum and writenum
    always_comb
    begin
    case(nsel)
        //Rm
        2'b00: begin
            readnum = in[2:0];
            writenum = in[2:0];
        end
        //Rd
        2'b01: begin
            readnum = in[7:5];
            writenum = in[7:5];
        end
        //Rn
        2'b10: begin
            readnum = in[10:8];
            writenum = in[10:8];
        end
        default: begin
            readnum = in[2:0];
            writenum = in[2:0];
        end
    endcase
    end
endmodule