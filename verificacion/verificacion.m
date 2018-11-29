% Checking dumped file
clear all;
close all;

%% Leyendo datos de simulacion MATLAB y VHDL

% Abriendo datos de simulacion MATLAB desde workspace guardado
load('ficheros_MATLAB/H_est_wkspc.mat');
H_real = H_real.';  % A vector columna

% Abriendo datos desde fichero VHDL
file_name = 'ficheros_VHDL/bloque_14_ch_est.txt';
fileID = fopen(file_name,'r');
data = fscanf(fileID, '%s');
data = reshape(data,6,[])';

re_hex = data(:, 1:3);  % Obteniendo parte real como string
im_hex = data(:, 4:6);  % Obteniendo parte imag como string

q = quantizer('fixed', [12 4]);         % Leyendolo desde punto fijo
H_est_vhdl_re = hex2num(q, re_hex);     % Pasando a parte real numerica
H_est_vhdl_im = hex2num(q, im_hex);     % Pasando a parte imag numerica

H_est_vhdl = H_est_vhdl_re + 1i*H_est_vhdl_im;   % Obteniendo el dato

clear('file_name', 'fileID', 'data', 're_hex', 'im_hex', 'q', 'H_est_vhdl_re','H_est_vhdl_im');

%% Transformando datos para representacion

% Transformamos frec para representacion
% Reprensentamos entre -fs/2 y fs/2
% Truncamos en f las frecuencias sin información
% Representamos en MHz
f_est = f - NFFT*Afc/2;
f_est = f_est(ceil((NFFT-Lsimb)/2)+(1:Lsimb));
f_est = f_est/1e6;

% Representamos el canal estimado, el canal real
% y el canal estimado por VHDL en dB
H_est_dB = 20*log10(abs(H_est));
H_real_dB = 20*log10(abs(H_real));
H_est_vhdl_dB = 20*log10(abs(H_est_vhdl));


figure;
plot(f_est, H_est_vhdl_dB, 'g', f_est, H_real_dB, 'b');
title('Canal real H(f) VS Canal estimado VHDL |H_V_H_D_L(f)|');
legend('|H_V_H_D_L(f)|','|H(f)|'); 
xlabel('f[MHz]');
ylabel('dB');

figure;
plot(f_est, H_est_vhdl_dB, 'g', f_est, H_est_dB, 'r');
title('Canal estimado VDHL H_V_H_D_L(f) VS Canal estimado MATLAB H_e_s_t(f)');
legend('|H_e_s_t(f)|','|H(f)|'); 
xlabel('f[MHz]');
ylabel('dB');

figure;
plot(f_est, H_est_dB,'r', f_est, H_real_dB, 'b', f_est, H_est_vhdl_dB, 'g');
title('Canal real H(dB) VS Canal estimado H_e_s_t(dB) VS Canal Estimado VHDL H_V_H_D_L(dB)');
legend('|H_e_s_t(f)|','|H(f)|', '|H_V_H_D_L(dB)|' ); 
xlabel('f[MHz]');
ylabel('dB');

% Calculo de error cuadratico medio
H_est_mod      = abs(H_est);
H_real_mod     = abs(H_real);
H_est_vhdl_mod = abs(H_est_vhdl);


mse_vhdl_matlab = mse(H_est_mod, H_est_vhdl_mod);
mse_vhdl_real   = mse(H_real_mod, H_est_vhdl_mod);
mse_matlab_real = mse(H_real_mod ,H_est_mod );


fprintf('MSE(H_est_vhdl, H_est_matlab) \t = %f \n', mse_vhdl_matlab);
fprintf('MSE(H_est_vhdl, H_real) \t = %f \n', mse_vhdl_real);
fprintf('MSE(H_est_matlab, H_real) \t = %f \n', mse_matlab_real);

