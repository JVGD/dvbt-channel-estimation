clc, clear all, close all;
load ../workbenches/symb_wb.mat

% Fixed point parms
signed = 1;
int_w = 8;
fra_w = 4;
word_w = int_w + fra_w;

pilots_signed = sign(1./pilots_tx) < 0;
N = length(pilots_rx);

for i = 1:N;
    pilot_rx_re = fi(real(pilots_rx(i)), signed, word_w, fra_w);
    pilot_rx_im = fi(imag(pilots_rx(i)), signed, word_w, fra_w);
    pilot_signed = pilots_signed(i);
    

    fprintf('wait for 10 ns;\n');
    fprintf('pilot_tx_signed_teo <= %c%d%c; \n', char(39), pilot_signed, char(39));
    fprintf('pilot_rx_teo.re <= x"%s";     -- d"%f" b"%s"\n', pilot_rx_re.hex, pilot_rx_re.data, pilot_rx_re.bin);
    fprintf('pilot_rx_teo.im <= x"%s";     -- d"%f" b"%s"\n', pilot_rx_im.hex, pilot_rx_im.data, pilot_rx_im.bin);
    fprintf('\n');
end

