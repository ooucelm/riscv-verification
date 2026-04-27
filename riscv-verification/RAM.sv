// RAM parametrizable: lectura asincrona, escritura sincrona, enable de lectura
module RAM #(
    parameter ANCHO = 32,              // bits por palabra
    parameter LARGO = 1024,            // numero de posiciones
    parameter INIT_FILE = ""           // fichero de inicializacion
)(
    input                        CLK,
    input                        write_enable,     // habilitacion de escritura
    input                        read_enable,      // habilitacion de lectura
    input  [$clog2(LARGO)-1:0]   addr,             // direccion
    input  [ANCHO-1:0]           din,              // datos de entrada
    output [ANCHO-1:0]           dout              // datos de salida
);

    // Memoria: LARGO x ANCHO
    reg [ANCHO-1:0] mem [0:LARGO-1];

    // Inicializacion opcional
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    // Escritura sincrona
    always @(posedge CLK) begin
        if (write_enable) begin
            mem[addr] <= din;
        end
    end

    // Lectura asincrona CON habilitacion
    assign dout = (read_enable) ? mem[addr] : {ANCHO{1'b0}};

endmodule
