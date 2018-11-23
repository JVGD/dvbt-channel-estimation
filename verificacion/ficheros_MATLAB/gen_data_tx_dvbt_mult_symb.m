%% Alumno: Fco Javier Vargas García-Donas
%  Electrónica Digital de comunicaciones
clear all; close all; clc;
%% Transmisor OFDM
    
    %% Datos iniciales
    clc; clear;

    NFFT = 2048;                    % Numero de portadoras totales
    NCP = NFFT/32;                  % 1/32 de prefijo ciclico
    Lsimb = 1705;                   % Portadoras usadas por simbolo OFDM
    Lpilot = length(1:12:1705);     % Numero portadoras de pilotos por simbolo
    Ldata = Lsimb - Lpilot;         % Numero portadoras de datos por simbolo
    
    NUM_SYMB = 1;       % Numero de simbolos OFDM por portadora en el tiempo, 
                        % es decir, cuantos simbolos se tx a lo largo de t
                        % esto determina el numero de muestras por portadora 
                        % (ofdm_freq)

    port_ep = 11;       % Num portadoras entre pilotos
    SEED = 100;
    CONSTEL = 'QPSK';   % Constelación
    SNR = 20;           % SNR en dB

    tic                 % Inicia cronómetro

    rand('seed', SEED); % Planta una semilla de una 
                        % distribución uniforme
    randn('seed',SEED); % Planta una semilla de una
                        % distribución gaussiana

    %% Constelación
    switch CONSTEL
        case 'BPSK'
            M = 1;      % Bits por símbolo
            C = [1 -1];
            potencia_norm = 1;
        case 'QPSK'
            C = [1+1i 1-1i -1+1i -1-1i];
                        % Están ordenados de una manera específica
                        % C(i) donde i= bitToDecimal(b0,b1) + 1
                        % con b0,b1 los bits a tx
            M = 2;      % Bits por símbolo
            potencia_norm = sqrt(2);
    end

    if isreal(C)
        C = complex(C);
    end

    %% Generación bits en vector columna
    % Generamos solo los bits de datos (los pilotos se insertan luego)
    numbits_data = NUM_SYMB * Ldata * M;
    bits_tx = rand(numbits_data, 1);
    bits_tx = bits_tx > 0.5;
                        % Al ejecutar la comparación devuelve un 0
                        % si falso o 1 si verdadero ==> bits                  

    %% PRBS - Generación de secuencia aleatoria
    prbs_end = NUM_SYMB * Lsimb;
    prbs_reg = ones(1,11);
    prbs = zeros(1, prbs_end);
            
    for k=1:prbs_end
        in = xor( prbs_reg(9), prbs_reg(end));
        out = prbs_reg(end);
        prbs_reg = [in prbs_reg(1:end-1)];       % Shift por concatenación
        prbs(k) = out;
    end
    
        % Volcando registro prbs a fichero
        % Fichero a volcar la info
        file_name = 'matlab_prbs.txt';
        fileID = fopen(file_name,'w');
        for k = 1:length(prbs)

        % Volcando en hexadecimal
        fprintf(fileID,'%d\n', prbs(k));

        end

    %% Generación de pilotos
    % Consideramos solo la salida del prbs para las posiciones de los 
    % pilotos, matriz cuyas columnas son simbolos y luego tan solo los
    % pilotos del simbolo
    pilots = reshape(prbs, Lsimb, NUM_SYMB);
    pilots = pilots(1:12:1705, :);
    
    % Configuramos su potencia
    pilots = (pilots > 0) * (-4/3) + (pilots == 0) * 4/3;
    pilots = complex(pilots);
    
        % Volcando pilotos rx a fichero
        % Fichero a volcar la info
        file_name = 'matlab_tx_pilots.txt';
        fileID = fopen(file_name,'w');

        for k = 1:length(pilots)

            % number, signed, 12bits, 4b decimal part
            re_fi = fi(real(pilots(k)), 1, 12, 4);
            im_fi = fi(imag(pilots(k)), 1, 12, 4);

            % Volcando en hexadecimal
            fprintf(fileID,'%s%s\n', re_fi.hex, im_fi.hex);

        end


    %% Pasamos los bits al símbolo
    % Se podría hacer con un for pero lo hacemos
    % matricialmente por velocidad
    aux = reshape(bits_tx, M, []).';
                        % Cambia la matrix bitx1 a una matrix 2xN/2
                        % la trasponemos luego para tener en columna
                        % reshape va rellenando por columnas!!
                        % NO ES LO MISMO A' que A.' uno es traspuesta
                        % y otro es la transpuesta conjugada
                        % poner [] es como dejar argumento en blanco
                        % matlab calcula el num de columnas para que
                        % esto sea coherente

    symb = zeros(size(aux,1),1);
                        % Vector columna de zeros de aux filas y 1 col
    for k = 1:M
        symb = symb + (2^(k-1))*aux(:,k);
    end
                        % Ahora symb son los bits pasados a decimal

    %% Mapeador
    tx_constel_data = C(symb + 1);
                        % Esto devuelve el valor de C para cada symb
                        % es como si fuera un for
    if isreal(tx_constel_data)
        tx_constel_data = complex(tx_constel_data);
    end

    %% Normalizamos en potencia
    % BPSK - No hace falta, potencia es 1
    % QPSK - Normalizamos entre raiz de 2
    tx_constel_data = tx_constel_data / potencia_norm;

    %% Insercion de pilotos y datos
    % Creamos variable vacia para los simbolos, cada columna un simbolo
    simbols = zeros(Lsimb, NUM_SYMB);
    
    % Transformamos los datos de entrada para, cada columna los datos
    % pertenecientes a un simbolo
    data = reshape(tx_constel_data, Ldata, NUM_SYMB);

    % Insertando pilotos
    simbols(1:12:1705,:) = pilots;
    
    % Hallando posiciones de datos
    mask_vect = ones(Lsimb,1);          % Vector 1x1705 que tendra 1
    mask_vect(1:12:1705) = 0;           % en las posiciones de datos y
    data_index = mask_vect == 1;        % 0 en la de los pilotos
    
    % Insertando datos
    simbols(data_index, :) = data;

    % Tenemos los datos y pilotos insertados
    % pero solo en las portadoras que no son
    % 0, ahora toca meterlas en el simbolo
    % entero con las portadoras a cero
                                

    %% Creación símbolos OFDM en frecuencia
    ofdm_freq = zeros(NFFT, NUM_SYMB);
    ofdm_freq(ceil((NFFT-Lsimb)/2)+(1:Lsimb),:) = simbols;

    %% Modulación OFDM
    % Hacemos la iffshift por columnas por eso (... , 1) muy importante
    % Los vectores columnas quedarian: [1 2 3 4]' ---> [3 4 1 2]'
    ofdm_freq_shifted = ifftshift(ofdm_freq,1);

    % Antitransformamos durante NFFT puntos y lo hacemos por columnas
    % de ahi que dim = 1, (mirar 'dim' en la ayuda de matlab)
    ofdm_time = ifft(ofdm_freq_shifted, NFFT, 1);

    %% Prefijo cíclico
    % Se ha definido que el prefijo cíclico tiene NCP muestras, por tanto
    % cogemos las NCP ultimas muestras y las copiamos al principio de modo
    % que nos quedará una trama de NFFT + NCP
    % Cogemos las NCP ultimas filas enteras (todas las columnas) y las ponemos
    % encima
    ofdm_time = [ ofdm_time( end-(NCP-1):end, : ) ; ofdm_time ];

    %% Configuramos la transmisión
    % Se ponen todos los bits uno detras de otro en orden
    tx = ofdm_time(:);


%% Canal
    
    %% Canal p1 dvbt
    % parametros
    % relative power
    rho = [0.057662, 0.176809, 0.407163,0.303585,0.258782,0.061831,0.150340,0.051534,0.185074,0.400967,0.295723,0.350825,0.262909,0.225894,0.170996,0.149723,0.240140,0.116587,0.221155,0.259730];

    % delay in us
    tau = [1.003019,5.422091,0.518650,2.751772,0.602895,1.016585,0.143556,0.153832,3.324866,1.935570,0.429948,3.228872,0.848831,0.073883,0.203952,0.194207,0.924450,1.381320,0.640512,1.368671];
    tau = tau .* 10^(-6);

    % phase in rads
    theta = [4.855121,3.419109,5.864470,2.215894,3.758058,5.430202,3.952093,1.093586,5.775198,0.154459,5.928383,3.053023,0.628578,2.128544,1.099463,3.462951,3.664773,2.833799,3.334290,0.393889];
    
    Ts = 224e-6;
    Afc = 1/Ts;
    f = (0:NFFT-1)*Afc;
    f = f-NFFT*Afc/2;

    % Generating the freq spectrum
    H = zeros(1,2048);

    for k = 1:20
        H = H + (rho(k) * exp(-1i*theta(k)) * exp(-1i*2*pi*f*tau(k)));
    end
    
    % De freq a tiempo
    % como H definida con f negativas
    % se hace ifftshift ante de antitransfromar
    h = ifft(ifftshift(H,2));
    H_dB = 20*log10(abs(H));

    %% Ruido
    noise = (randn(size(tx))+ 1i * randn(size(tx))) / sqrt(2);
                          % Dividimos entre raiz de dos para normalizar la
                          % potencia
    Ps = mean (tx.*conj(tx));
    nsr = 10^(-SNR/10);
    noise = sqrt(Ps * nsr) .* noise;
    
    
    % Metiendo el ruido
    rx = tx + noise;

    % Metemos el fading 
    rx = conv(h,rx);
    rx = rx(1:size(tx));
    
    
%% Receptor OFDM
    
    %% Quitar el prefijo ciclico
    % Formateamos rx para quitarle el prefijo cíclico
    rx_ofdm_time = reshape(rx, NFFT+NCP, NUM_SYMB);

    % Le quitamos el prefijo ciclico, ponemos un NCP+1
    % porque empieza en el indice 1 y no en 0
    rx_ofdm_time = rx_ofdm_time((NCP+1):end, :);

    %% Pasar al dominio de la frecuencia
    % Transformamos por columnas para las NFFT celdas de cada columna
    rx_ofdm_freq = fft(rx_ofdm_time, NFFT, 1);

    % Formateamos el espectro en frecuencias negativas
    rx_ofdm_freq = fftshift(rx_ofdm_freq,1);

    % Dibujamos las portadoras en frecuencia para el primer simbolo
    f = (0:NFFT-1)*Afc;
    f_plot = (f-NFFT*Afc/2)/1e6;    % Frec centrada en cero y en MHz

       
    %% Quitamos las portadoras sin informacion
    % Misma operacion que antes, nos quedamos desde NFFT-NDATA/2 hasta NDATA
    rx_ofdm_freq = rx_ofdm_freq(ceil((NFFT-Lsimb)/2)+(1:Lsimb),:);

        % Usamos solo el primer simbolo OFDM
        ofdm = rx_ofdm_freq(:,1);

        % Fichero a volcar la info
        file_name = 'matlab_symbOFDM.txt';
        fileID = fopen(file_name,'w');

        for k = 1:length(ofdm)

            % number, signed, 12bits, 4b decimal part
            re_fi = fi(real(ofdm(k)), 1, 12, 4);
            im_fi = fi(imag(ofdm(k)), 1, 12, 4);

            % Volcando en hexadecimal
            fprintf(fileID,'%s%s\n', re_fi.hex, im_fi.hex);

        end
    

    %% Estimador de canal
    % rx_ofdm_freq viene entre -fs/2 y fs/2 por tanto
    % H_est también lo estará

    % Sacamos los pilotos recibidos
    rx_pilots = rx_ofdm_freq(1:12:end, :);
    
        % Volcando pilotos rx a fichero
        % Fichero a volcar la info
        file_name = 'matlab_rx_pilots.txt';
        fileID = fopen(file_name,'w');

        for k = 1:length(rx_pilots)

            % number, signed, 12bits, 4b decimal part
            re_fi = fi(real(rx_pilots(k)), 1, 12, 4);
            im_fi = fi(imag(rx_pilots(k)), 1, 12, 4);

            % Volcando en hexadecimal
            fprintf(fileID,'%s%s\n', re_fi.hex, im_fi.hex);

        end
    
    
    % Estimamos con los pilotos recibidos
    % estimacion de canal por simbolos (columnas)
    Hp_est = rx_pilots./pilots;
    
        tx_pilots = pilots; % only for saving
        save('pilots_est_wkspc', 'tx_pilots','rx_pilots');
        
        tx_pilots_inv = 1./tx_pilots;
        
        rxpfi_re = fi(real(rx_pilots), 1, 12, 4);
        txpfi_inv_re = fi(real(tx_pilots_inv), 1, 12, 4);
        rxpfi_im = fi(imag(rx_pilots), 1, 12, 4);
        txpfi_inv_im = fi(imag(tx_pilots_inv), 1, 12, 4);

        estpfi_re = rxpfi_re.* txpfi_inv_re;
        estpfi_im = rxpfi_im.* txpfi_inv_re;

        q = fixed.Quantizer(1,12,4);

        estpfi_q_re = quantize(q, estpfi_re);
        estpfi_q_im = quantize(q, estpfi_im);

        % Volcando pilotos rx a fichero
        % Fichero a volcar la info
        file_name = 'matlab_pilots_est.txt';
        fileID = fopen(file_name,'w');

        for k = 1:length(estpfi_re)
            re_fi = estpfi_q_re(k);
            im_fi = estpfi_q_im(k);
            % Volcando en hexadecimal
            fprintf(fileID,'%s%s\n', re_fi.hex, im_fi.hex);

        end
    
    % Definimos el canal estimado
    H_est = zeros(Lsimb, NUM_SYMB);

    % Rellenamos con los pilotos estimados
    H_est(1:12:end, :) = Hp_est;
    
    % Comprobando que los pilotos coinciden con
    % el valor del canal correcatmente
   
    f_neg = f-NFFT*Afc/2;
    f_neg = f_neg(ceil((NFFT-Lsimb)/2)+(1:Lsimb));
    
    % Estimacion en dB del canal del primer simb
    H_est_dB = 20*log10(abs(H_est(:,1)));
    
    % Dibujando H contra los pilotos recibidos
    H_trunked = H;
    H_trunked = H_trunked((ceil((NFFT-Lsimb)/2)+(1:Lsimb)));
    H_trunked = 20 * log10( abs(H_trunked) );
    
    % Definimos intervalo de interpolacion
    x = [1:11].';

    % Definimos indice para los datos interpolados
    index = (1:12:Lsimb-1)+1;

    % Interpolamos los datos y los metemos en H_est
    for k = 1:length(Hp_est(:,1))-1
        H_est_data = (x./12) * Hp_est(k+1,:) + ((12-x)./12) * Hp_est(k,:);
        H_est(index(k):index(k)+10, :) = H_est_data;
    end
        
        % Volcando el canal estimado a fichero
        % Fichero a volcar la info
        file_name = 'matlab_H_est.txt';
        fileID = fopen(file_name,'w');

        for k = 1:length(H_est)

            % number, signed, 12bits, 4b decimal part
            re_fi = fi(real(H_est(k)), 1, 12, 4);
            im_fi = fi(imag(H_est(k)), 1, 12, 4);

            % Volcando en hexadecimal
            fprintf(fileID,'%s%s\n', re_fi.hex, im_fi.hex);

        end
    

    %% Dibujamos canal estimado VS canal real
    % Para la representacion
    % Reprensentamos entre -fs/2 y fs/2
    f_est = f - NFFT*Afc/2;

    % Truncamos en f las frecuencias sin información
    f_est = f_est(ceil((NFFT-Lsimb)/2)+(1:Lsimb));

    % Representamos en MHz
    f_est = f_est/1e6;
    f_data = f_est;

    % Representamos H entre -fs/2 y fs/2 para ello
    % Truncamos en f las frecuencias sin información
    H_real = H((ceil((NFFT-Lsimb)/2)+(1:Lsimb)));
    
    % Volcando H_est canal estimado y canal real
    % Volcando info a wkspc 
    save('H_est_wkspc', 'H_est', 'H_real', 'f', 'NFFT', 'Afc', 'Lsimb');

    

    %% Ecualización
    % Dividimos entre el canal estimado para ecualizar
    rx_ofdm_freq = rx_ofdm_freq./H_est;

    % Dibujamos portadoras ecualizadas, para ello buscamos
    % añadir ceros en portadoras sin informacion para representar
    rx_portadoras = rx_ofdm_freq(:,1).';
    neg_zero_pad = ceil((NFFT - Lsimb)/2);
    pos_zero_pad = floor((NFFT - Lsimb)/2);
    rx_portadoras = [zeros(1,neg_zero_pad) rx_portadoras zeros(1,pos_zero_pad)];
    f_rx_port = f - NFFT*Afc/2 ;

    %% Quitamos los pilotos

    % Nos quedamos con los datos que estan
    % en las posiciones data_index definidas
    % antes como el vector en el que no estan
    % los pilotos
    rx_constel_data = rx_ofdm_freq(data_index, :);
    
    % Pasandolo a un vector de simbolos
    rx_constel_data = rx_constel_data(:);
    
    %% Demapper
    % BPSK
    %   Si bit < 0 entonces es un 1
    %   Si bit > 1 entonces es un 0
    % QPSK
    %   Tiene 2 bits (b1 y b0) por simbolo en orden: b1b0
    %   Si parte real negativa b0 = 1 si positiva b0 = 0
    %   Si parte real negativa b1 = 1 si positiva b1 = 0
    %   01 | 00     -1+i | 1+i      b1b0 | b1b0      
    %   --------    -----------     -----------     
    %   11 | 10     -1-i | 1-i      b1b0 | b1b0      
    switch CONSTEL
        case 'BPSK'
            bits_rx = rx_constel_data<0;
            bits_rx = bits_rx.';
        case 'QPSK'
            bits_rx = zeros(1,length(rx_constel_data)*2);
            bits_rx(2:2:end) = real(rx_constel_data)<0;
            bits_rx(1:2:end) = imag(rx_constel_data)<0;
    end

    BER = mean(xor(bits_rx, bits_tx.'));
    fprintf(1, 'BER = %f\n', BER);
    toc
    
% Saving workbench variables
pilots_rx = rx_pilots;
pilots_tx = pilots;
symb_rx = rx_ofdm_freq;
    
    
    
    
