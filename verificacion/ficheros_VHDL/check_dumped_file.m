% Fichero para comprobar que valores HEX en fichero
% son correctos. Dado un fichero de texto symbOFDM.txt
% lee los valores como entrada y los interpreta
% como simbolos OFDM


% Checking dumped file
clear all;
close all;

% Comprobando que las portadoras son bien volcadas
% Fichero a volcar la info
file_name = 'symbOFDM.txt';
fileID = fopen(file_name,'r');
data = fscanf(fileID, '%s');
data = reshape(data,6,[])';

re_hex = data(:, 1:3);
im_hex = data(:, 4:6);

q = quantizer('fixed', [12 4]);
ofdm_re = hex2num(q, re_hex);
ofdm_im = hex2num(q, im_hex);

ofdm = ofdm_re + i*ofdm_im;
ofdm(1:10)