clc, clear all, close all;
load ../workbenches/symb_wb.mat

%% Calculation in floating point
% Estimando pilotos
Hp_est = pilots_rx./pilots_tx;

% Definimos el canal estimado
Lsimb = 1705; NUM_SYMB = 1;
H_est = zeros(Lsimb, NUM_SYMB);

% Rellenamos con los pilotos estimados
H_est(1:12:end, :) = Hp_est;

% Definimos intervalo de interpolacion
x = [1:11].';

% Definimos indice para los datos interpolados
index = (1:12:Lsimb-1)+1;

% Interpolamos los datos y los metemos en H_est
% for k = 1:length(Hp_est(:,1))-1
for k = 1:1    
    H_est_data = (x./12) * Hp_est(k+1,:) + ((12-x)./12) * Hp_est(k,:);
    H_est(index(k):index(k)+10, :) = H_est_data;
end

%% Calculation in fixed point
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

% for i=1:length(pilots_est_fi)-1
for i=1:1    
    smultA = pilots_est_fi(i) * coefA;
    smultB = pilots_est_fi(i+1) * coefB;
    ssum = smultB + smultA;
    interp = quantize(q, ssum);
end

% Watching the interpolation error introduced
% due to fixed point and coefs
H_est_data_fi = fi(H_est_data, signed, word_w, fra_w);
H_est_data_fi = H_est_data_fi.hex();
interpolad = interp.data();
interpolad_fi = interp.hex();
t = table(H_est_data, interpolad);
disp('Watching the interpolation error:')
disp(t)

% Getting the error
coefB_float = x./12;          % Pilot inf
coefA_float = (12-x)./12;     % Pilot sup
coefA_fixed = coefA.data();
coefB_fixed = coefB.data();
error_A = abs(coefA_float - coefA_fixed);
error_B = abs(coefB_float - coefB_fixed);
t = table(coefA_float,coefA_fixed,error_A,coefB_float,coefB_fixed,error_B);
disp('Watching the coef quantization/fixed point error:')
disp(t)


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
file_name = 'matlab_H_est_interp.txt';
fileID = fopen(file_name,'w');

% Writing first pilot to file
pilot1 = pilots_est_fi(1);
pilot1_re = real(pilots_est_fi(1));
pilot1_im = imag(pilots_est_fi(1));
fprintf(fileID,'%s%s\n', pilot1_re.hex, pilot1_im.hex);

% for i=1:length(pilots_est_fi)-1 
for i=1:1     
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
    
    % Pilot sup
    sup = pilots_est_fi(i+1);
    sup_re = real(sup);
    sup_im = imag(sup);
    fprintf(fileID,'%s%s\n', sup_re.hex, sup_im.hex);
end

%% Generating VHDL code for testbench
for i = 1:length(Hp_est)-1;
    
    % Printing IN pilots into interpolator
    inf_re = fi(real(Hp_est(i)), signed, word_w, fra_w);
    inf_im = fi(imag(Hp_est(i)), signed, word_w, fra_w);
    
    sup_re = fi(real(Hp_est(i+1)), signed, word_w, fra_w);
    sup_im = fi(imag(Hp_est(i+1)), signed, word_w, fra_w);
    
    fprintf('wait for 250 ns;\n');
    fprintf('valid <= %c%d%c;   -- inf and sup valid data\n', char(39), 1, char(39));
    fprintf('inf.re <= x"%s";   -- d"%f" b"%s"\n', inf_re.hex, inf_re.data, inf_re.bin);
    fprintf('inf.im <= x"%s";   -- d"%f" b"%s"\n', inf_im.hex, inf_im.data, inf_im.bin);
    fprintf('sup.re <= x"%s";   -- d"%f" b"%s"\n', sup_re.hex, sup_re.data, sup_re.bin);
    fprintf('sup.im <= x"%s";   -- d"%f" b"%s"\n', sup_im.hex, sup_im.data, sup_im.bin);
    fprintf('\n');	
    fprintf('wait for 10 ns;\n');
    fprintf('valid <= %c%d%c;   -- inf and sup valid data\n', char(39), 0, char(39));
    fprintf('\n');	
    
end