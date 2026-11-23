module cpu_tb_top (
    input logic clk,
    input logic rst,
    input logic [31:0] Instr
);
    logic [31:0] result_impl, result_spec;
    logic [31:0] pc_impl, pc_spec;
    logic legal_instruction;

    cpu u_impl (
        .clk(clk), .rst(rst), .Instr(Instr),
        .PC(pc_impl), .Result(result_impl)
    );

    cpu_behavioral u_spec (
        .clk(clk), .rst(rst), .Instr(Instr),
        .PC(pc_spec), .Result(result_spec)
    );

    // Six legal operation encodings; operands/immediates remain symbolic.
    assign legal_instruction =
        ((Instr[6:0] == 7'b0010011) &&
         (Instr[14:12] == 3'b000)) || // ADDI
        ((Instr[6:0] == 7'b0110011) &&
         (((Instr[31:25] == 7'b0000000) &&
           ((Instr[14:12] == 3'b000) || // ADD
            (Instr[14:12] == 3'b111) || // AND
            (Instr[14:12] == 3'b110) || // OR
            (Instr[14:12] == 3'b010))) || // SLT
          ((Instr[31:25] == 7'b0100000) &&
           (Instr[14:12] == 3'b000)))); // SUB

    assume_legal_instruction: assume property (
        @(posedge clk) disable iff (rst) legal_instruction
    );

    assert_result_match: assert property (
        @(posedge clk) disable iff (rst)
        result_impl == result_spec
    );

    assert_pc_match: assert property (
        @(posedge clk) disable iff (rst)
        pc_impl == pc_spec
    );

    // Guide additions: confirm that both instruction categories are reachable.
    cover_rtype: cover property (
        @(posedge clk) disable iff (rst)
        legal_instruction && Instr[6:0] == 7'b0110011
    );

    cover_itype: cover property (
        @(posedge clk) disable iff (rst)
        legal_instruction && Instr[6:0] == 7'b0010011
    );
endmodule