% Data coding
    % Data coded as a word of:
    %   8 bits of integer part
    %   4 bits of fractionary part
    % word = [ 8bits, 4 bits ]

    % Complex data coded as 2 words
    % complex = [real_word, imag_word]

% Coding prbs output sequence
    % If prbs(k) > 0 => pilot(k) = real(-4/3)
    % If prbs(k) < 0 => pilot(k) = real(+4/3)

    % number, signed, 12bits, 4b decimal part
    pilot_pos_re = fi(4/3, 1, 12, 4);
    pilot_pos_im = fi(0, 1, 12, 4);
    
    pilot_neg_re = fi(-4/3, 1, 12, 4);
    pilot_neg_im = fi(0, 1, 12, 4);

    % Dumping in hexadecimal
    fprintf('\nHex Representation\n');
    fprintf('Positive pilot (prbs = 0) = %s%s\n', pilot_pos_re.hex, pilot_pos_im.hex);
    fprintf('Negative pilot (prbs = 1) = %s%s\n', pilot_neg_re.hex, pilot_neg_im.hex);
    
    % Dumping in binary
	fprintf('\nHex Representation\n');
    fprintf('Positive pilot (prbs = 0) = %s%s\n', pilot_pos_re.bin, pilot_pos_im.bin);
    fprintf('Negative pilot (prbs = 1) = %s%s\n', pilot_neg_re.bin, pilot_neg_im.bin);
    
    % Looking at decimal values
    pilot_pos_re
    pilot_neg_re
    
    