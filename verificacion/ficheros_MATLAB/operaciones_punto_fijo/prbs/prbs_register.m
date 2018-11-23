% PRBS
NUM_SYMB = 1;
Lsimb = 1705;
prbs_end = NUM_SYMB * Lsimb;
prbs_reg = ones(1,11);
prbs = zeros(1, prbs_end);

for k=1:prbs_end
    out = prbs_reg(11);
    in = xor( prbs_reg(9), prbs_reg(11));
    prbs_reg = [in prbs_reg(1:end-1)];
    prbs(k) = out;
end

prbs'

% Validacion bloque 5
% Volcando el canal estimado a fichero
% Fichero a volcar la info
file_name = 'matlab_prbs.txt';
fileID = fopen(file_name,'w');

for k = 1:length(prbs)

    % Volcando en hexadecimal
    fprintf(fileID,'%d\n', prbs(k));

end

