#!/bin/bash
echo "Verifying generated symbol, bloque_2 output, showing differences...   "
diff -iu matlab_symbOFDM.txt bloque_2_generated.txt
echo "... Done!"
echo " "

echo "Verifying PRBS, bloque_5 output, showing differences...   "
diff -ui matlab_prbs.txt bloque_5_generated.txt
echo "... Done!"
echo " "

echo "Verifying, RX pilots, bloque_8 input, showing differences...   "
diff -ui matlab_rx_pilots.txt bloque_8_rx_pilots.txt
echo "... Done!"
echo " "

echo "Verifying, TX pilots, bloque_8 input, showing differences...   "
diff -ui matlab_tx_pilots.txt bloque_8_tx_pilots.txt
echo "... Done!"
echo " "
