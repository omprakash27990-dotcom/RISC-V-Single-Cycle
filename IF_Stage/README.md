 module IFSTAGE (
    input logic [31:0]pc_signed_offset,
    input logic clk,reset,stall,and_out,
    output logic[31:0]address,pc_new);
    
    assign pc_new=address +32'd4;
    logic[31:0] pc_next;
    always_comb
    begin
    if (and_out)
    pc_next=pc_signed_offset;
    else
    pc_next=pc_new;
    end
    always_ff @(posedge clk or posedge reset) begin
    if (reset)
    address <=32'h8000_0001;
    else
    if (!stall)
    address <=pc_next;
    end
    endmodule
