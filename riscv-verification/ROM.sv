// ROM parametrizable: lectura asíncrona
module ROM #(
    parameter ANCHO = 32,              // bits por palabra
    parameter LARGO = 1024,            // número de posiciones
    parameter INIT_FILE = ""           // fichero de inicialización
)(
    input  [$clog2(LARGO)-1:0] addr,   // dirección (log2(LARGO) bits)
    output [ANCHO-1:0] dout
);
    // Memoria: LARGO x ANCHO
    reg [ANCHO-1:0] mem [0:LARGO-1];

    // Inicialización opcional
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem); 
        end
    end

    // Lectura asíncrona
    assign dout = mem[addr];

endmodule
