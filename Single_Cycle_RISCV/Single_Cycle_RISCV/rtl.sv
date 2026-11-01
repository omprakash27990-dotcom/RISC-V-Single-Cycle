 module single_cycle_riscv (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] mem_out,
    output logic [31:0] rs2_data,
    output logic [31:0] alu_out,
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,
    output logic [6:0]  opcode,
    output logic [31:0] address
);

    // IF Stage signals
    logic [31:0] pc_new;

    // ID Stage signals
    logic [31:0] rs1_data;
    logic [31:0] imm_out;
    logic [6:0]  imm11_5;
    logic [2:0]  fn3_out_d;
    logic        fn7_5;
    logic [2:0]  aluop;
    logic [1:0]  memtoreg;
    logic        branch;
    logic        alu_src;
    logic        mux_inp;

    // EX Stage signals
    logic        and_out_ex;
    logic [31:0] pc_ex_out;

    // WB Stage signal
    logic [31:0] wb_data;

    // Connect instruction outputs
    assign opcode = instruction[6:0];
    assign fn3    = instruction[14:12];

    // ---------------- IF STAGE ----------------
    if_stage if_inst (
        .clk              (clk),
        .reset            (reset),
        .stall            (stall),
        .and_out          (and_out_ex),
        .pc_signed_offset (pc_ex_out),
        .address          (address),
        .pc_new            (pc_new)
    );

    // ---------------- ID STAGE ----------------
    id_stage id_inst (
        .clk          (clk),
        .reset        (reset),
        .stall        (stall),
        .instruction  (instruction),
        .wb_data      (wb_data),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .imm_out      (imm_out),
        .opcode_out_d (opcode),
        .imm11_5      (imm11_5),
        .fn3_out_d    (fn3_out_d),
        .fn7_5        (fn7_5),
        .aluop        (aluop),
        .memtoreg     (memtoreg),
        .branch       (branch),
        .mem_write    (mem_write),
        .mem_read     (mem_read),
        .alu_src      (alu_src),
        .mux_inp      (mux_inp)
    );

    // ---------------- EX STAGE ----------------
    ex_stage ex_inst (
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data),
        .imm_out   (imm_out),
        .address   (address),
        .branch    (branch),
        .alu_src   (alu_src),
        .fn7_5     (fn7_5),
        .mux_inp   (mux_inp),
        .fn3       (fn3_out_d),
        .imm11_5   (imm11_5),
        .aluop     (aluop),
        .opcode    (opcode),
        .and_out_ex(and_out_ex),
        .alu_out   (alu_out),
        .pc_ex_out (pc_ex_out)
    );

    // ---------------- WB STAGE ----------------
    wb_stage wb_inst (
        .mem_out          (mem_out),
        .alu_out          (alu_out),
        .return_addr      (pc_new),
        .imm_out          (imm_out),
        .pc_signed_offset (pc_ex_out),
        .memtoreg         (memtoreg),
        .opcode_out_d     (opcode),
        .wb_data          (wb_data)
    );

endmodule
