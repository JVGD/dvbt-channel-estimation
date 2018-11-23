% Making sure var exists
if ( exist('pilots', 'var') && exist('rx_pilots', 'var')) 
    fprintf('\nDivision with fixed point:\n\n');
else
    tx_dvbt_mult_symb;
    close all;
end;

% For naming clarity
tx_pilots = pilots;

% Estimated pilots
pilots_est = rx_pilots ./ tx_pilots;

% In fixed point
pilots_est_re = fi(real(pilots_est), 1, 12, 4);
pilots_est_im = fi(imag(pilots_est), 1, 12, 4);

fprintf('Estimated Pilots\n');
for k = 1:length(pilots_est)
    
    % just for printing
    pilots_est_re = fi(real(pilots_est(k)), 1, 12, 4);
    pilots_est_im = fi(imag(pilots_est(k)), 1, 12, 4);
    fprintf('%s%s\n', pilots_est_re.hex, pilots_est_im.hex);
end

fprintf('\nFirst pilot\n');

fprintf('Real division\n');
    pilot_re = fi(real(pilots_est(1)), 1, 12, 4);
    pilot_im = fi(imag(pilots_est(1)), 1, 12, 4);
    fprintf('%s%s\n', pilot_re.hex, pilot_im.hex);
    
fprintf('Fixed point division\n');
    pilot_re = fi(real(pilots_est(1)), 1, 12, 4);
    pilot_im = fi(imag(pilots_est(1)), 1, 12, 4);
    fprintf('%s%s\n', pilot_re.hex, pilot_im.hex);
    

    fprintf('HOW TO DIVIDE BETWEEN COMPLEX NUMBER IN VHDL???\n');

