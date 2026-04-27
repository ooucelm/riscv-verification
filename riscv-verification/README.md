**RISC-V (RV32I) Processor Design & Verification**

Se ha diseñado y verificado un procesador basado en **RISC-V (RV32I)** en **SystemVerilog**, implementando una arquitectura **monociclo** como *golden model* y una versión **segmentada de 5 etapas (pipeline)** para mejorar el rendimiento.

**🔬 Rol Principal: Verificación Funcional**

Responsable del desarrollo completo del entorno de verificación, realizado de forma autónoma, sin asistencia externa.

**🧪 Testbenches**

Se han desarrollado distintos testbenches en SystemVerilog con el objetivo de validar el comportamiento del procesador en sus diferentes arquitecturas.

El testbench `tb_TOP_CORE.sv` se encarga de la verificación de la arquitectura monociclo y se utiliza como referencia funcional para validar el resto del sistema.

El testbench `tb_TOP_CORE_seg.sv` está orientado a la validación del procesador segmentado, asegurando la correcta ejecución del pipeline y la coherencia de los datos entre sus distintas etapas.

Por último, `tb_CORE_seg_gmodel` constituye el testbench principal de verificación avanzada, en el que se implementa una comparación directa entre el modelo monociclo (golden model) y el modelo segmentado, permitiendo validar la equivalencia funcional entre ambas arquitecturas.

------

🇬🇧 English Version
**RISC-V (RV32I) Processor Design & Verification**

A **RISC-V (RV32I)** processor was designed and verified in **SystemVerilog**, implementing a **single-cycle architecture** as a *golden model* and a **5-stage pipelined version** to improve performance.

**🔬 Main Role: Functional Verification**

Responsible for the full development of the verification environment, carried out independently without external assistance.

**🧪 Testbenches**

Several testbenches were developed in SystemVerilog to validate the processor behavior across its different architectures.

The `tb_TOP_CORE.sv` testbench verifies the single-cycle architecture and is used as a functional reference for system validation.

The `tb_TOP_CORE_seg.sv` testbench focuses on the pipelined processor, ensuring correct pipeline execution and data consistency across stages.

Finally, `tb_CORE_seg_gmodel` is the main advanced verification testbench, implementing a direct comparison between the single-cycle (golden model) and the pipelined architecture, enabling functional equivalence validation.
