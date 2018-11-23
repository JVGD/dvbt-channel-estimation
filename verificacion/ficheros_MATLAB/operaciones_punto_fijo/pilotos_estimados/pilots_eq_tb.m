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

for i = 1:length(pilots_rx);
    pilot_rx_re = fi(real(pilots_rx(i)), signed, word_w, fra_w);
    pilot_rx_im = fi(imag(pilots_rx(i)), signed, word_w, fra_w);
    
    pilot_eq_re = fi(real(pilots_eq(i)), signed, word_w, fra_w);
    pilot_eq_im = fi(imag(pilots_eq(i)), signed, word_w, fra_w);
    
    pilot_signed = pilots_signed(i);
    

    fprintf('wait for 10 ns;\n');
    fprintf('pilot_signed <= %c%d%c; \n', char(39), pilot_signed, char(39));
    fprintf('pilot_rx.re <= x"%s";     -- d"%f" b"%s"\n', pilot_rx_re.hex, pilot_rx_re.data, pilot_rx_re.bin);
    fprintf('pilot_rx.im <= x"%s";     -- d"%f" b"%s"\n', pilot_rx_im.hex, pilot_rx_im.data, pilot_rx_im.bin);
    fprintf('pilot_eq_teo.re <= x"%s"; -- d"%f" b"%s"\n', pilot_eq_re.hex, pilot_eq_re.data, pilot_eq_re.bin);
    fprintf('pilot_eq_teo.im <= x"%s"; -- d"%f" b"%s"\n', pilot_eq_im.hex, pilot_eq_im.data, pilot_eq_im.bin);
    fprintf('\n');	    
end



% 
