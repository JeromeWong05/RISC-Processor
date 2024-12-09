


//new addition constant 
`define MREAD 2'd0
`define MNONE 2'd1 
`define MWRITE 2'd2


module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output reg [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    //declare some regs and wires
    wire [8:0] mem_addr;
    reg [15:0] read_data; 
    wire [1:0] mem_cmd; 
    wire [15:0] dout; 
    reg [15:0] write_data; 
    wire write; 

    //not sure what to do with the N, V, Z flags 
    wire N, V, Z; 

    
    //instantiate all the modules 
    RAM MEM(.clk(~KEY[0]), 
            .read_address(mem_addr[7:0]), 
            .write_address(mem_addr[7:0]), 
            .write(write),
            .din(write_data),
            .dout(dout));


    cpu CPU(.clk(~KEY[0]),
            .reset(~KEY[1]), 
            .out(write_data), 
            .N(N), 
            .V(V), 
            .Z(Z),
            .read_data(read_data), 
            .mem_addr(mem_addr), 
            .mem_cmd(mem_cmd)); 

    //assign the HEX display of the three flags like in lab 6
    assign HEX5[0] = ~Z;
    assign HEX5[6] = ~N;
    assign HEX5[3] = ~V;
    assign {HEX5[2:1],HEX5[5:4]} = 4'b1111;

    //turn off all the HEX
    assign HEX0 = {7{1'b1}};
    assign HEX1 = {7{1'b1}};
    assign HEX2 = {7{1'b1}};
    assign HEX3 = {7{1'b1}};
    assign HEX4 = {7{1'b1}};

    //turn off the unused LEDR
    assign LEDR[9:8] = 2'b00;

    //assign write input 
    assign write = (mem_cmd == `MWRITE && mem_addr[8] == 1'b0) ? 1'b1 : 1'b0; 


    //switches logic 
    always_comb
    begin
        if (mem_cmd == `MREAD && mem_addr[8] == 1'b0)
            read_data = dout; 
        else if (mem_cmd == `MREAD && mem_addr == 9'h140)
        begin
            read_data[7:0] = SW[7:0];
            read_data[15:8] = 8'h00; 
        end
        else 
            read_data = {16{1'bz}};
    end

    //LED logic 
    always_ff @(negedge KEY[0])
    begin
        LEDR[7:0] = (mem_cmd == `MWRITE && mem_addr == 9'h100) ? write_data[7:0] : LEDR[7:0];
    end


endmodule




// To ensure Quartus uses the embedded MLAB memory blocks inside the Cyclone
// V on your DE1-SoC we follow the coding style from in Altera's Quartus II
// Handbook (QII5V1 2015.05.04) in Chapter 12, “Recommended HDL Coding Style”
//
// 1. "Example 12-11: Verilog Single Clock Simple Dual-Port Synchronous RAM 
//     with Old Data Read-During-Write Behavior" 
// 2. "Example 12-29: Verilog HDL RAM Initialized with the readmemb Command"

module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 16; 
  parameter addr_width = 8;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule
