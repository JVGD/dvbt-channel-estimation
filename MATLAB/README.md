# MATLAB Project

--- 

Esta carpeta incluye los siguientes subdirectorios y carpetas:

* `operaciones_fixed_point`: experimentos con operaciones con la herramienta de fixed point en MATLAB
* `interpolator`: ficheros para verificar el funcionamiento del interpolador VHDL con el framework de punto fijo de MATLAB
* `operaciones_pilotos`: ficheros para determinar el error introducido con la dinamica de punto fijo en VHDL en el bloque 9 de la arquitectura
* `prbs`: ficheros para la validación del bloque 5 de la arquitectura, el PRBS
* `symb_data_generator`: fichero generador y ficheros generados de datos para realizar la validación cruzada con los datos producidos por el VHDL
* `tx_dvbt_mult_symb.m`: fichero MATLAB donde se implementa el transmisor y receptor DVBT multi símbolo
* `verification_files`: ficheros generados por el simulador VHDL y un test bench para la cross validación
* `workbenches`: workbenches de datos generados en MATLAB para su uso en diferentes scripts

TODO:
1. Comparativa de error MATLAB - VHDL en distintos puntos del sistema
2. Comparativa de canal estimado MATLAB vs VHDL