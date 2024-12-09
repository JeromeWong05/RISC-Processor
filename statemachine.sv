
`define decode     6'd0

// First MOV operation
`define mov10      6'd1

// Second MOV operations
`define mov20      6'd2
`define mov21      6'd3
`define mov22      6'd4

// First ALU operation
`define alu10      6'd5
`define alu11      6'd6
`define alu12      6'd7
`define alu13      6'd8

// Second ALU operation
`define alu20      6'd9
`define alu21      6'd10
`define alu22      6'd11

// Third ALU operation
`define alu30      6'd12
`define alu31      6'd13
`define alu32      6'd14
`define alu33      6'd15

// Fourth ALU operation
`define alu40      6'd16
`define alu41      6'd17
`define alu42      6'd18

// New addition states / changes
`define RST        6'd19
`define IF1        6'd20
`define IF2        6'd21
`define UpdatePC   6'd22

`define ldrorstr1  6'd23
`define ldrorstr2  6'd24
`define ldr3       6'd25
`define ldr4       6'd26
`define ldr5       6'd27

`define str1       6'd28
`define str2       6'd29
`define str3       6'd30
`define str4       6'd31

`define halt1      6'd32
`define halt2      6'd33



//new addition constant 
`define MREAD 2'd0
`define MNONE 2'd1 
`define MWRITE 2'd2



module statemachine(clk,opcode, op, reset, write, loada, loadb, loadc, loads, asel, bsel, nsel, vsel,
                    //new addition: 
                    reset_pc, load_pc, load_ir, addr_sel, mem_cmd, load_addr);

    input [2:0] opcode;
    input [1:0] op; 
    input reset, clk;

    output reg [1:0] nsel, vsel;
    output reg write, loada, loadb, loadc, loads, asel, bsel;     

    //new addition: 
    output reg reset_pc, load_pc, load_ir, addr_sel, load_addr; 
    output reg [1:0] mem_cmd; 

    reg [5:0] pstate;

    //state machine logic 
    always_ff @(posedge clk)
    begin

    //resets logic 
    if (reset)
    begin
        reset_pc = 1; 
        load_pc = 1; 
        pstate = `RST;  
    end 
    else begin

    case(pstate)
    //RST state 
    `RST: 
    begin
        //make sure all the datapath control signals are instantiated
        loada = 0; 
        loadb = 0; 
        loadc = 0; 
        loads = 0; 
        asel = 1; 
        bsel = 1; 
        write = 0; 

        //new control signals 
        reset_pc = 0; 
        load_pc = 0; 
        load_ir = 0; 
        load_addr = 0; 
        addr_sel = 0; 
        mem_cmd = `MNONE;

        pstate = `IF1;
    end

    //instruction fetch 1
    `IF1: begin
        //again need to make sure all signals are reset 
        loada = 0; 
        loadb = 0; 
        loadc = 0; 
        loads = 0; 
        asel = 1; 
        bsel = 1; 
        write = 0; 
        reset_pc = 0; 
        load_pc = 0; 
        load_ir = 0; 
        load_addr = 0; 
        mem_cmd = `MNONE;

        addr_sel = 1; 
        mem_cmd = `MREAD; 

        pstate = `IF2; 
    end

    //instruction fetch 2
    `IF2: begin
        load_ir = 1; 
        pstate = `UpdatePC; 
    end

    //update pc state
    `UpdatePC: begin
        mem_cmd = `MNONE; 
        load_ir = 0; 
        load_pc = 1; 
        addr_sel = 0; 

        pstate = `decode; 
    end

    //decode stage 
    `decode: begin
        load_pc = 0; 
        
    if (opcode == 3'b110)
    begin
        if (op == 2'b10)
            pstate = `mov10; 
        else if (op == 2'b00)
            pstate = `mov20; 
        else pstate = `RST;
    end

    else if (opcode == 3'b101)
    begin
        if (op == 2'b00)
            pstate = `alu10;
        else if (op == 2'b01)
            pstate = `alu20; 
        else if (op == 2'b10)
            pstate = `alu30; 
        else 
            pstate = `alu40; 
    end

    else if ((opcode == 3'b011 || opcode == 3'b100) && op == 2'b00)
        pstate = `ldrorstr1; 

    else if (opcode == 3'b111)
        pstate = `halt1; 
    
    else   
        pstate = `RST; 
    end

    //new addition instructions 

    //LDR operation
    `ldrorstr1: begin
        nsel = 2'b10; 
        write = 0; 
        loada = 1; 
        pstate = `ldrorstr2; 
    end
    `ldrorstr2: begin
        loada = 0; 
        asel = 0; 
        bsel = 1; 
        loadc = 1; 
        if (opcode == 3'b011)
            pstate = `ldr3; 
        else if (opcode == 3'b100)
            pstate = `str1; 
        else 
            pstate = `RST; 
    end

    //continute the ldr op 
    `ldr3: begin
        load_addr = 1; 
        loadc = 0; 
        pstate = `ldr4; 
    end
    `ldr4: begin
        addr_sel = 0; 
        mem_cmd = `MREAD; 
        pstate = `ldr5; 
    end
    `ldr5: begin
        vsel = 2'b11; 
        write = 1; 
        nsel = 2'b01; 
        pstate = `IF1; 
    end


    //the store instruction
    `str1: begin
        loadc = 0; 
        load_addr = 1; 
        pstate = `str2; 
    end
    `str2: begin
        load_addr = 0; 
        nsel = 2'b01; 
        loadb = 1; 
        pstate = `str3; 
    end
    `str3: begin
        asel = 1; 
        bsel = 0; 
        loadc = 1; 
        pstate = `str4; 
    end
    `str4: begin
        loadc = 0; 
        addr_sel = 0; 
        mem_cmd = `MWRITE; 
        pstate = `IF1; 
    end

    `halt1: begin
        reset_pc = 1; 
        load_pc = 1; 
        pstate = `halt2; 
    end
    `halt2: begin
        reset_pc = 0; 
        load_pc = 0; 
    end




    //first move operation 
    `mov10: 
    begin
        nsel = 2'b10;
        vsel = 2'b10; 
        write = 1; 
        pstate = `IF1; 
    end

    //second move operation
    `mov20: 
    begin
        nsel = 2'b00; 
        write = 0; 
        loadb = 1; 
        loada = 1; 
        pstate = `mov21; 
    end
    `mov21: 
    begin
        loada = 0; 
        loadb = 0; 
        loadc = 1; 
        asel = 1; 
        bsel = 0; 
        pstate = `mov22; 
    end
    `mov22: 
    begin
        loadc = 0; 
        vsel = 2'b00; 
        write = 1; 
        nsel = 2'b01; 
        pstate = `IF1; 
    end

    //first alu operation
    `alu10: 
    begin
        write = 0; 
        loada = 1; 
        nsel = 2'b10; 
        pstate = `alu11; 
    end
    `alu11: 
    begin
        loada = 0; 
        loadb = 1; 
        nsel = 2'b00; 
        pstate = `alu12; 
    end
    `alu12: 
    begin
        asel = 0; 
        bsel = 0; 
        loadc = 1; 
        loadb = 0; 
        pstate = `alu13; 
    end
    `alu13: 
    begin
        write = 1; 
        nsel = 2'b01; 
        vsel = 2'b00; 
        pstate = `IF1; 
    end

    //second alu operation
    `alu20: 
    begin
        write = 0; 
        loada = 1; 
        nsel = 2'b10; 
        pstate = `alu21; 
    end 
    `alu21: 
    begin
        loada = 0; 
        loadb = 1; 
        nsel = 2'b00; 
        pstate = `alu22; 
    end
    `alu22:
    begin
        asel = 0; 
        bsel = 0; 
        loads = 1; 
        loadb = 0; 
        pstate = `IF1; 
    end

    //third alu operation 
    `alu30: 
    begin
        write = 0; 
        loada = 1; 
        nsel = 2'b10; 
        pstate = `alu31; 
    end
    `alu31: 
    begin
        loada = 0; 
        loadb = 1; 
        nsel = 2'b00; 
        pstate = `alu32;
    end
    `alu32: 
    begin
        asel = 0; 
        bsel = 0; 
        loadc = 1; 
        loadb = 0; 
        pstate = `alu33; 
    end
    `alu33: 
    begin
        nsel = 2'b01; 
        write = 1; 
        vsel = 2'b00; 
        pstate = `IF1; 
    end

    //fourth alu operation 
    `alu40: 
    begin
        write = 0; 
        loada = 0; 
        loadb = 1; 
        nsel = 2'b00; 
        pstate = `alu41; 
    end
    `alu41: 
    begin
        loadb = 0; 
        asel = 1; 
        bsel = 0; 
        loadc = 1; 
        pstate = `alu42; 
    end
    `alu42: 
    begin
        nsel = 2'b01; 
        write = 1; 
        vsel = 2'b00; 
        pstate = `IF1; 
    end

    

    endcase
    end
    end



endmodule 