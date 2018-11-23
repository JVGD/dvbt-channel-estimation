x = 4;
y = 3;
r = 4/3;
s = 1/r;
t = -s;

signed = 1;
int_w = 8;
fra_w = 4;
word_w = int_w + fra_w;

X = fi(x, signed, word_w, fra_w);
Y = fi(y, signed, word_w, fra_w);
R = fi(r, signed, word_w, fra_w);
S = fi(s, signed, word_w, fra_w);
T = fi(t, signed, word_w, fra_w);

fprintf('x: %f, X: %f 0x %s 0b %s\n', x, X.data, X.hex, X.bin);
fprintf('y: %f, Y: %f 0x %s 0b %s\n', y, Y.data, Y.hex, Y.bin);
fprintf('r: %f, R: %f 0x %s 0b %s\n', r, R.data, R.hex, R.bin);
fprintf('s: %f, S: %f 0x %s 0b %s\n', s, S.data, S.hex, S.bin);
fprintf('t: %f, T: %f 0x %s 0b %s\n', t, T.data, T.hex, T.bin);
    
    
    
    
    
    