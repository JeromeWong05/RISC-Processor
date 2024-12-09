


module datapath (mdata, sximm8, PC, sximm5, clk,readnum,vsel,loada,loadb,shift,asel,bsel,ALUop,loadc,loads,writenum,write,datapath_in,Z_out,datapath_out,V_out,N_out);

    //all the inputs and outputs
    input clk,loada, loadb, asel, bsel, loadc, loads, write;
    input [2:0] readnum, writenum;
    input [15:0] datapath_in; 
    input [1:0] shift, ALUop; 
    output reg [15:0] datapath_out; 
    output reg Z_out, V_out, N_out;  

    //new additions
    input [15:0] mdata, sximm8, sximm5; 
    input [7:0] PC; 
    input [1:0] vsel; 


    //for the register files
    wire [15:0] data_out; 
    reg [15:0] data_in; 

    //for the ALU block  
    wire [15:0] Ain, Bin, out;
    reg outputZ, outputN, outputV; 

    //for the shifter block
    wire [15:0] in;
    wire [1:0] shift; 
    wire [15:0] sout;  

    //for the pipeline registers
    reg [15:0] outA, outB, outC; 
    
//better to instantiate the ports using dot
    regfile REGFILE(.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out));

    ALU alu_path(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(out), .Z(outputZ), .V(outputV), .N(outputN)); 

    shifter shifter_path(.in(outB), .shift(shift), .sout(sout));

    //(NEW)vsel multiplexer 
    always_comb
    begin
       case(vsel)
       2'b00: data_in = datapath_out; 
       2'b01: data_in = {{8{1'b0}}, PC};
       2'b10: data_in = sximm8; 
       2'b11: data_in = mdata; 
       endcase 
    end
    
    //pipeline register A
    always_ff @(posedge clk)
    begin
        outA <= (loada == 1) ? data_out : outA; 
    end

    //pipeline register B
    always_ff @(posedge clk)
    begin
        outB <= (loadb == 1) ? data_out : outB; 
    end

    //path for Bin
    assign Bin = (bsel == 1) ? sximm5 : sout;

    //path for Ain 
    assign Ain = (asel == 1) ? 16'b0 : outA; 

    //status register
    always_ff @(posedge clk)
    begin
        if (loads == 1'b1)
        begin
            Z_out <= outputZ; 
            N_out <= outputN; 
            V_out <= outputV; 
        end
    end
    

    //final output pipeline register C
    always_ff @(posedge clk)
    begin
        datapath_out <= (loadc == 1) ? out : datapath_out;  
    end

endmodule