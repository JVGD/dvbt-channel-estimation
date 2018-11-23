clear all;
load pilots_est_wkspc

% Floating point calc
est_pilots = rx_pilots./tx_pilots;

% Fixed point
% pilots_est = pilots
tx_pilots_inv = 1./tx_pilots;

rxpfi = fi(real(rx_pilots), 1, 12, 4);
txpfi_inv = fi(real(tx_pilots_inv), 1, 12, 4);

%% Only with one
r = rxpfi(1);
ti = txpfi_inv(1);

e = r * ti;
% It does the [15:4] automatically
q = fixed.Quantizer(1,12,4);
eq = quantize(q, e);

disp('Calculation with only one')
disp(['r = ',r.hex()])
disp(['ti = ',ti.hex ])
disp 'e = r * ti'
disp ' '
disp 'Quantization '
disp(['e = ',e.hex()])
disp 'eq = q(e)'
disp(['eq = ',eq.hex()])

%% Calculation with all

rxpfi_re = fi(real(rx_pilots), 1, 12, 4);
txpfi_inv_re = fi(real(tx_pilots_inv), 1, 12, 4);
rxpfi_im = fi(imag(rx_pilots), 1, 12, 4);
txpfi_inv_im = fi(imag(tx_pilots_inv), 1, 12, 4);

estpfi_re = rxpfi_re.* txpfi_inv_re;
estpfi_im = rxpfi_im.* txpfi_inv_re;

q = fixed.Quantizer(1,12,4);

estpfi_q_re = quantize(q, estpfi_re);
estpfi_q_im = quantize(q, estpfi_im);

% For displaying purposes
estpfi_re1 = estpfi_re(1:5);
estpfi_q_re1 = estpfi_q_re(1:5);
disp ' '
disp('Calculation with all')
disp('estpfi_re(1:5) = ')
disp(estpfi_re1.hex())
disp('estpfi_q_re(1:5) = ')
disp(estpfi_q_re1.hex())


% Volcando pilotos rx a fichero
% Fichero a volcar la info
file_name = 'matlab_pilots_est_fi.txt';
fileID = fopen(file_name,'w');

for k = 1:length(estpfi_q_re)
    re_fi = estpfi_q_re(k);
    im_fi = estpfi_q_im(k);
    % Volcando en hexadecimal
    fprintf(fileID,'%s%s\n', re_fi.hex, im_fi.hex);

end

%% Comparing error introduced
est_pilots(1:5)
estpfi_q_re = estpfi_q_re.data();
estpfi_q_im = estpfi_q_im.data();
est_pilots_fi = estpfi_q_re + 1i * estpfi_q_im;
est_pilots_fi(1:5)

mse_est_pilots = mse(est_pilots, est_pilots_fi);


disp 'Mean Squared Error:'
disp(mse_est_pilots)
