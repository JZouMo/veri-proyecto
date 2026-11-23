// 32-bit RISC-V Single-Cycle Processor (Behavioral)

module cpu_behavioral (
    input logic clk,
    input logic rst,
    input logic [31:0] Instr,
    output logic [31:0] PC,
    output logic [31:0] Result
);
    logic [31:0] register_bank [0:31];
    logic [4:0] rd, rs1, rs2;
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;
    logic [31:0] operand_a, operand_b, immediate;
    logic write_enable;
    integer i;

    assign rd = Instr[11:7];
    assign rs1 = Instr[19:15];
    assign rs2 = Instr[24:20];
    assign opcode = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7 = Instr[31:25];
    assign immediate = {{20{Instr[31]}}, Instr[31:20]};
    assign operand_a = (rs1 == 0) ? 32'b0 : register_bank[rs1];
    assign operand_b = (rs2 == 0) ? 32'b0 : register_bank[rs2];

    // Combinational prediction for the six supported operations.
    always_comb begin
        Result = 32'b0;
        write_enable = 1'b0;
        if (opcode == 7'b0010011 && funct3 == 3'b000) begin
            Result = operand_a + immediate; // ADDI
            write_enable = 1'b1;
        end else if (opcode == 7'b0110011) begin
            case ({funct7, funct3})
                {7'b0000000, 3'b000}: begin // ADD
                    Result = operand_a + operand_b;
                    write_enable = 1'b1;
                end
                {7'b0100000, 3'b000}: begin // SUB
                    Result = operand_a - operand_b;
                    write_enable = 1'b1;
                end
                {7'b0000000, 3'b111}: begin // AND
                    Result = operand_a & operand_b;
                    write_enable = 1'b1;
                end
                {7'b0000000, 3'b110}: begin // OR
                    Result = operand_a | operand_b;
                    write_enable = 1'b1;
                end
                {7'b0000000, 3'b010}: begin // SLT, course convention
                    Result = ($signed(operand_a) < $signed(operand_b))
                             ? 32'hffffffff : 32'h00000000;
                    write_enable = 1'b1;
                end
                default: begin
                    Result = 32'b0;
                    write_enable = 1'b0;
                end
            endcase
        end
    end

    // State updates happen at the same edge as the implementation.
    always_ff @(posedge clk) begin
        if (rst) begin
            PC <= 32'h00400000;
            for (i = 0; i < 32; i = i + 1) begin
                register_bank[i] <= 32'b0;
            end
        end else begin
            PC <= PC + 32'd4;
            if (write_enable && rd != 0)
                register_bank[rd] <= Result;
        end
    end
endmodule
