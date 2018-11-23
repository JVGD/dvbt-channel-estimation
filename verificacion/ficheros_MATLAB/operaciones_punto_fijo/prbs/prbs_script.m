clear all; close all;

Lsimb = 1705;                   % Portadoras usadas por simbolo OFDM
NUM_SYMB = 1; 

prbs_end = NUM_SYMB * Lsimb;
prbs_reg = ones(1,11);
prbs = zeros(1, prbs_end);

for k=1:prbs_end
    in = xor( prbs_reg(9), prbs_reg(end));
    out = prbs_reg(end);
    prbs_reg = [in prbs_reg(1:end-1)];       % Shift por concatenación
    prbs(k) = out;
end

test = [1 1 1 1 1 1 1 1 1 1 1 0 0]'
prbs = prbs';
prbs(1:13)
