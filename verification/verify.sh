#!/bin/bash

diff -ui matlab_symbOFDM.txt      bloque_2_rx_symb.txt
diff -ui matlab_symbOFDM.txt      bloque_3_rx_symb.txt
diff -ui matlab_prbs.txt          bloque_5_prbs.txt
diff -ui matlab_tx_pilots.txt     bloque_8_tx_pilots.txt
diff -ui matlab_rx_pilots.txt     bloque_8_rx_pilots.txt
diff -ui matlab_pilots_est.txt    bloque_9_pilots_est.txt
