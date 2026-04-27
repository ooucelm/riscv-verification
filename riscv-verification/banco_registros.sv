module banco_registros(
    input  logic        CLK, RST_n,
    input  logic [4:0]  readReg1, readReg2, writeReg,
    input  logic [31:0] writeData,
    input  logic        RegWrite,
    output logic [31:0] readData1, readData2
);

logic [31:0] registro [31:0]; // 32 registros de 32 bits

always_ff @(posedge CLK or negedge RST_n) begin
    if (!RST_n) begin
        registro <= '{default:0};   // reset a cero
    end else begin
        registro[0] <= 32'b0;       // x0 siempre vale 0
        if (RegWrite && writeReg != 5'd0)
            registro[writeReg] <= writeData;
    end
end

assign readData1 = registro[readReg1];
assign readData2 = registro[readReg2];

endmodule

