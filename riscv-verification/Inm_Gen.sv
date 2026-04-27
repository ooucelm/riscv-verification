module Inm_Gen (
    input  logic [31:0] inst,   // instrucción completa
    output logic [31:0] inm      // inmediato sign-extendido
);

    // Opcode de la instucción
    logic [6:0] opcode;
    assign opcode = inst[6:0];

    // Opcodes RV32I que usamos en el proyecto
    localparam logic [6:0]
        OPCODE_LOAD   = 7'b0000011, // LW
        OPCODE_OPinm  = 7'b0010011, // ADDi, ANDi, ...
        OPCODE_STORE  = 7'b0100011, // SW
        OPCODE_BRANCH = 7'b1100011, // BEQ, BNE, BGE
        OPCODE_LUI    = 7'b0110111, // LUI
        OPCODE_AUIPC  = 7'b0010111, // AUIPC
        OPCODE_JAL = 7'b1101111, //JAL
        OPCODE_JALR = 7'b1100111; //JALR

    always_comb begin
        unique case (opcode)

            // ======================= I-TYPE ==========================
            // LW (LOAD) y ALU inmediatas (ADDi, ANDi, SLTi, ...)
            OPCODE_LOAD,
            OPCODE_OPinm: begin
                // inm[31:0] = sign-extend(inst[31:20])
                inm = {{20{inst[31]}}, inst[31:20]};
            end

            // ======================= S-TYPE ==========================
            // SW
            OPCODE_STORE: begin
                // inm[31:0] = sign-extend(inst[31:25] inst[11:7])
                inm = {{20{inst[31]}},
                        inst[31:25],
                        inst[11:7]};
            end

            // ======================= B-TYPE ==========================
            // BEQ, BNE, BGE (todas usan el mismo formato B)
            OPCODE_BRANCH: begin
                // inm[31:0] = sign-extend( inst[31] inst[7]
                //                           inst[30:25] inst[11:8] 0 )
                inm = {{19{inst[31]}},
                        inst[31],
                        inst[7],
                        inst[30:25],
                        inst[11:8],
                        1'b0};
            end

            // ======================= U-TYPE ==========================
            // LUI y AUIPC (mismo formato)
            OPCODE_LUI,
            OPCODE_AUIPC: begin
                // inm[31:0] = inst[31:12] << 12
                inm = {inst[31:12], 12'b0};
            end
            OPCODE_JAL: begin
                inm = {{11{inst[31]}},   // sign-extend desde imm[20]
                       inst[31],         // imm[20]
                       inst[19:12],      // imm[19:12]
                       inst[20],         // imm[11]
                       inst[30:21],      // imm[10:1]
                       1'b0};             // imm[0] = 0
              end
            OPCODE_JALR: begin
                inm = {{20{inst[31]}}, inst[31:20]};
              end
            // ======================= R-TYPE / otros ==================
            // ADD, SUB, SLT, ... no tienen inmediato
            default: begin
                inm = 32'd0;
            end

        endcase
    end

endmodule
