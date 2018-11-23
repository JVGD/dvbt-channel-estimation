% Division checker
y = 3;
x = 2;
z = y/x;

% fixed point params
int_width = 3;
frac_width = 3;
word_len = int_width + frac_width;
signed = 1;

% fixed point representation
Y = fi(y, signed, word_len, frac_width);
X = fi(x, signed, word_len, frac_width);
Z = fi(z, signed, word_len, frac_width);

% Results
fprintf('\n\n');
fprintf('Division params:\n');
fprintf('Word Length: %d\n',word_len);
fprintf('Inte Length: %d\n',int_width);
fprintf('Frac Length: %d\n\n',frac_width);

fprintf('Division %.2f/%.2f = %.2f\n', y, x, z);
fprintf('Division %f/%f = %.2f\n\n', Y.data, X.data, Z.data);

fprintf('Y: %f, 0x %s, 0b %s\n',Y.data, Y.hex, Y.bin);
fprintf('X: %f, 0x %s, 0b %s\n',X.data, X.hex, X.bin);
fprintf('Z: %f, 0x %s, 0b %s\n',Z.data, Z.hex, Z.bin);
