#!/bin/bash
echo -n "Verifying bloque_2 output, showing differences...   "
diff -iu matlab_symbOFDM.txt bloque_2_generated.txt
echo "... Done!"
echo -n "Verifying bloque_5 output, showing differences...   "
diff -ui matlab_prbs.txt bloque_5_generated.txt
echo "... Done!"
