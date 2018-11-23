clc, clear all, close all;
load ../workbenches/symb_wb.mat

% Fixed point parms
signed = 1;
int_w = 8;
fra_w = 4;
word_w = int_w + fra_w;

pilots_tx_inv = 1./pilots_tx;
pilots_eq = pilots_rx .* pilots_tx_inv;
pilots_signed = sign(pilots_tx_inv) < 0;

for i = 1:length(pilots_eq);
    
    pilot_eq_re = fi(real(pilots_eq(i)), signed, word_w, fra_w);
    pilot_eq_im = fi(imag(pilots_eq(i)), signed, word_w, fra_w);
    
    fprintf('wait for 10 ns;\n');
    fprintf('pilot_eq_valid <= %c%d%c; \n', char(39), 1, char(39));
    fprintf('pilot_eq.re <= x"%s"; -- d"%f" b"%s"\n', pilot_eq_re.hex, pilot_eq_re.data, pilot_eq_re.bin);
    fprintf('pilot_eq.im <= x"%s"; -- d"%f" b"%s"\n', pilot_eq_im.hex, pilot_eq_im.data, pilot_eq_im.bin);
    fprintf('\n');	    
end



% 
