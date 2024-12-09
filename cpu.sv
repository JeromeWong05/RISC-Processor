



module cpu(clk,reset,out,N,V,Z,read_data,mem_addr,mem_cmd);
    input clk, reset;
    input [15:0] read_data;
    
    output reg [15:0] out;
    output reg N, V, Z;
    output reg [1:0] mem_cmd; 
    output reg [8:0] mem_addr; 
    


    //wires and regs for instruction register
    reg [15:0] instruction_reg_out; 

    //declaring wires and regs 
    reg write, loada, loadb, loadc, loads, asel, bsel; 
    reg [1:0] nsel, vsel; 

    wire [2:0] readnum, writenum; 
    wire [2:0] opcode; 
    wire [15:0] sximm5, sximm8; 
    wire [1:0] ALUop, shift, op; 

    //new additions 
    wire load_ir, reset_pc, load_pc, addr_sel, load_addr; 
    reg [8:0] next_pc, PC, data_address_reg; 



    //state machine instantiation
    statemachine statemachine(.reset(reset), //inputs
                                .opcode(opcode),
                                .op(op),
                                .clk(clk),
                                //outputs
                                .write(write),
                                .loada(loada),
                                .loadb(loadb),
                                .loadc(loadc),
                                .loads(loads),
                                .asel(asel),
                                .bsel(bsel),
                                .nsel(nsel),
                                .vsel(vsel), 
                                //new additions
                                .mem_cmd(mem_cmd),
                                .reset_pc(reset_pc), 
                                .load_pc(load_pc), 
                                .load_ir(load_ir), 
                                .addr_sel(addr_sel), 
                                .load_addr(load_addr));

    //instruction decoder instantiation
    instructiondecoder instructiondecoder(.in(instruction_reg_out),
                                            .nsel(nsel),
                                            .opcode(opcode),
                                            .op(op),
                                            .ALUop(ALUop),
                                            .sximm5(sximm5),
                                            .sximm8(sximm8),
                                            .shift(shift),
                                            .readnum(readnum),
                                            .writenum(writenum));

    //datapath instantiation
    datapath DP(        .mdata(read_data),
                        .sximm8(sximm8),
                        .PC(8'b0), 
                        .sximm5(sximm5),
                        .clk(clk),
                        .writenum(writenum),
                        .readnum(readnum),
                        .vsel(vsel),
                        .asel(asel),
                        .bsel(bsel),
                        .loada(loada),
                        .loadb(loadb),
                        .loadc(loadc),
                        .loads(loads),
                        .shift(shift),
                        .write(write),
                        .ALUop(ALUop),
                        .Z_out(Z),
                        .V_out(V),
                        .N_out(N),
                        .datapath_in(sximm8),
                        .datapath_out(out));


     
    always_ff @(posedge clk)
    begin
        //instruction register
        instruction_reg_out = (load_ir) ? read_data : instruction_reg_out; 

        //program counter register
        PC = (load_pc) ? next_pc : PC;

        //data address register 
        data_address_reg = (load_addr) ? out[8:0] : data_address_reg;
    end





    always_comb 
    begin
        //next_pc mux
        next_pc = (reset_pc) ? 9'b0 : PC + 9'd1; 

        //mem_addr mux
        mem_addr = (addr_sel) ? PC : data_address_reg; 
    end



endmodule