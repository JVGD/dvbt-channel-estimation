%% Calculation and dumping to file for check
load ../workbenches/symb_wb.mat
% Fixed point parms
signed = true;
int_w = 8;
fra_w = 4;
word_w = int_w + fra_w;

% Getting the coeficients
% from the interp
coefB = x./12;          % Pilot sup
coefA = (12-x)./12;     % Pilot inf

% 5 bits, with 4 frac for coefs
coef_word = 5;
coefA = fi(coefA, signed, coef_word, fra_w);
coefB = fi(coefB, signed, coef_word, fra_w);

% Fixed point of pilots for interpolation
pilots_est_fi = fi(Hp_est, signed, word_w, fra_w);
% Quantizer for trimming the operations
q = fixed.Quantizer(signed, word_w, fra_w);

% Writing data to file
disp 'Writing file...'
file_name = 'matlab_interpoled_data.txt';
fileID = fopen(file_name,'w');

for i=1:length(pilots_est_fi)-1 
    smultA = pilots_est_fi(i) * coefA;
    smultB = pilots_est_fi(i+1) * coefB;
    ssum = smultB + smultA;
    interp = quantize(q, ssum);
    
    % Dumping to file
    for k = 1:length(interp)
        interp_re = real(interp(k));
        interp_im = imag(interp(k));
        fprintf(fileID,'%s%s\n', interp_re.hex, interp_im.hex);
    end
    
end
disp '...Done!'