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
                        % Vector del 0 al numero en el plano complejo
                        % hipotenusa de 0 a Re = 1, Im = 1i => Z=1+1i
    end

    if isreal(C)
        C = complex(C); % Para propositos de representacion
    end

    %% Generación bits en vector columna
    % Generamos solo los bits de datos (los pilotos se insertan luego)
    % Se tiene en cuenta que en QPSK son M=2 bit por simbolo y en BPSK
    % son solo M=1 bit por simbolo
    numbits_data = NUM_SYMB * Ldata * M;
    bits_tx = rand(numbits_data, 1);
    bits_tx = bits_tx > 0.5;
                        % Al ejecutar la comparación devuelve un 0
                        % si falso o 1 si verdadero => bits                  

    %% PRBS - Generación de secuencia aleatoria
    prbs_end = NUM_SYMB * Lsimb;
    prbs_reg = ones(1,11);
    prbs = zeros(1, prbs_end);

    for k=1:prbs_end
        in = xor( prbs_reg(9), prbs_reg(end) );
        out = prbs_reg(end);
        prbs_reg = [in prbs_reg(1:end-1)];       % Shift por concatenación
        prbs(k) = out;
    end

    %% Generación de pilotos
    % Consideramos solo la salida del prbs para las posiciones de los 
    % pilotos, matriz cuyas columnas son simbolos y luego tan solo los
    % pilotos del simbolo
    pilots = reshape(prbs, Lsimb, NUM_SYMB); 
                        % Matriz [Lsim x N_SYMB] = [1705 x 3]
    pilots = pilots(1:12:1705, :);
                        % Matriz [Lpilot x N_SYMB] = [143 x 3]
                        
    % Configuramos potencia de pilotos de acuerdo al estandar
    pilots = (pilots > 0) * (-4/3) + (pilots == 0) * 4/3;
    pilots = complex(pilots);   % Para propositos de representacion


    %% Pasamos los bits al símbolo
    % Se podría hacer con un for pero lo hacemos
    % matricialmente por velocidad
    aux = reshape(bits_tx, M, []).';
                        % Matrix = [Ldata*NSYMB x M]
                        % Matriz auxiliar que ordena en cada fila
                        % los bits por simbolo de la constelacion
                        % si BPSK M=1 bit/symb si QPSK M=4 bit/symb

    symb = zeros(size(aux,1),1);
                        % Vector de simbolos de la constelacion
                        
    for k = 1:M
        symb = symb + (2^(k-1))*aux(:,k);
                        % Pasa los bits de aux a decimal:
                        % BPSK: [0,1]
                        % QPSK: [0,1,2,3]
                        % El "+" esta porque lo hace iterativamente 
                        % primero convierte el bit en posicion 1 (2^0) 
                        % y luego el 2 (2^1)
    end

    %% Mapeador
    tx_constel_data = C(symb + 1);
                        % Aprovechando la manera en la que esta ordanado 
                        % el vector C, es simbolo de la constelacion es
                        % constel: C(i) donde i= bitToDecimal(b0,b1) + 1
                        % El +1 es porque MATLAB empieza en 1 el indice

    if isreal(tx_constel_data)
        tx_constel_data = complex(tx_constel_data);
                        % Para propositos de representacion
    end

    %% Normalizamos en potencia
    % BPSK - No hace falta, potencia es 1
    % QPSK - Normalizamos entre raiz de 2 (modulo de 1+1j)
    tx_constel_data = tx_constel_data / potencia_norm;

    %% Dibujamos los simbolos
    % Debe salir lo mismo que la primera gráfica pero con los puntos
    % machacados sobre si mismos

    figure;
    plot(tx_constel_data, 'or');      
                        % Si vector es entero numero complejos plot
                        % los pinta en eje Re e Im, si C es real le
                        % añadimos una Im = 0 para que no de error
    grid;
    axis([-1.5 1.5 -1.5 1.5]);
    title('Constelacion (normalizado en potencia)');
    xlabel('Re');
    ylabel('Im');

    %% Insercion de pilotos y datos
    % Creamos variable vacia para los simbolos, cada columna un simbolo
    simbols = zeros(Lsimb, NUM_SYMB);
    
    % Transformamos los datos de entrada para, cada columna los datos
    % pertenecientes a un simbolo data: [Ldata x NUM_SYMB]
    data = reshape(tx_constel_data, Ldata, NUM_SYMB);

    % Insertando pilotos en posiciones fijas para cada simbolo
    simbols(1:12:1705,:) = pilots;
    
    % Hallando posiciones de datos 
    % usando una mascara
    mask_vect = ones(Lsimb,1);          % Mascara 1x1705 que tendra 1
    mask_vect(1:12:1705) = 0;           % en las posiciones de datos y
    data_index = mask_vect == 1;        % 0 en la de los pilotos
    
    % Insertando datos
    simbols(data_index, :) = data;

    % Tenemos los datos y pilotos insertados
    % pero solo en las portadoras que no son
    % 0, ahora toca meterlas en el simbolo
    % entero con las portadoras a cero
                                

    %% Creación símbolos OFDM en frecuencia
    % Metemos las portadoras de informacion en medio
    % del simbolo OFDM en frecuencia dejando las portadoras
    % de los extremos a 0
    ofdm_freq = zeros(NFFT, NUM_SYMB);
    ofdm_freq(ceil((NFFT-Lsimb)/2)+(1:Lsimb),:) = simbols;

    %% Dibujamos portadoras
    figure;
    stem( abs(ofdm_freq(:,1)) );
                          % Elegimos el instante 1 para ver la energías:
                          % vemos todas las portadoras con la misma energía
                          % porque en la QPSK la diferencia esta en la fase
    grid;
    xlabel('Portadoras OFDM');
    ylabel('Amplitud');
    title('Espectro OFDM');

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
    % Esto serializa por columnas a vector columna
    tx = ofdm_time(:);

    %% Dibujamos
    ts = 224e-6;
    t_v = ts * (0:length(tx)-1);
    
    figure;
    plot(t_v, real(tx), 'b-');
    hold on; 

    plot(t_v, imag(tx), 'r-');
    grid;
    
    xlabel('t [s]');
    ylabel('Amplitud');
    title('OFDM tiempo');

    %% Espectro de frecuencias para el primer simbolo
    figure;
    pwelch(tx(1:NFFT+NCP));
    


%% Canal
    
    %% Canal p1 dvbt
    % Parametros
    % Potencia relativa
    rho = [0.057662, 0.176809, 0.407163,0.303585,0.258782,0.061831,0.150340,0.051534,0.185074,0.400967,0.295723,0.350825,0.262909,0.225894,0.170996,0.149723,0.240140,0.116587,0.221155,0.259730];

    % Retraso en us
    tau = [1.003019,5.422091,0.518650,2.751772,0.602895,1.016585,0.143556,0.153832,3.324866,1.935570,0.429948,3.228872,0.848831,0.073883,0.203952,0.194207,0.924450,1.381320,0.640512,1.368671];
    tau = tau .* 10^(-6);

    % Fase en rads
    theta = [4.855121,3.419109,5.864470,2.215894,3.758058,5.430202,3.952093,1.093586,5.775198,0.154459,5.928383,3.053023,0.628578,2.128544,1.099463,3.462951,3.664773,2.833799,3.334290,0.393889];
    
    % Calculo de la respuesta frecuencial del canal ya que debido
    % a los parametros dados es mas facil calcular la respuesta frec
    % y antitransformar
    Ts = 224e-6;            % Calculo de la f discreta en funcion de Tx
    Afc = 1/Ts;             % Resolucion maxima de frecuencias
    f = (0:NFFT-1)*Afc;     % Vector de frecuencias discretas
    f = f-NFFT*Afc/2;       % Vector de frecuencias discretas y negativas

    % Generado el espectro de frecuencias
    H = zeros(1,2048);

    % Formula de acuerdo al estandar del canal P2
    for k = 1:20
        H = H + (rho(k) * exp(-1i*theta(k)) * exp(-1i*2*pi*f*tau(k)));
    end
    
    % Antitransformando para obtener respuesta temporal
    % como H definida con f negativas
    % se hace ifftshift ante de antitransfromar
    h = ifft(ifftshift(H,2));
    H_dB = 20*log10(abs(H));

    %% Dibujamos el canal
    figure;
    plot(f/1e6, H_dB,'b');
    
    title('Canal P1 DVBT')
    xlabel('f[MHz]')
    ylabel('|H(f)| [dB]')
    grid;

    %% Ruido
    noise = (randn(size(tx))+ 1i * randn(size(tx))) / sqrt(2);
                            % Dividimos entre raiz de dos para normalizar
                            % la potencia del ruido complejo
    
    Ps = mean(tx.*conj(tx));    
                            % Calcular la potencia de una señal con media
                            % cero es como calcular la variaza de la misma
                            % Var = E((X-mean(x))^2) = E(X*X')
    
	nsr = 10^(-SNR/10);     % snr[u.n.] de SNR[dB]
    noise = sqrt(Ps * nsr) .* noise;
    
    % Metiendo el ruido aditivo (+)
    rx = tx + noise;

    % Metemos el fading (conv) y quitando
    % las muestras de sobra de la convolucion
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
    
    figure;
    subplot(2,1,1);
    plot( f_plot , abs( rx_ofdm_freq(:, 1) ) );
    title('Portadoras Recibidas');
    ylabel('|s_R_X(f)|');
    xlabel('f[MHz]');
    
    subplot(2,1,2);
    plot( f_plot , abs( ofdm_freq(:, 1) ) );
    title('Portadoras Transmitidas');
    xlabel('f[MHz]');
    ylabel('|s_T_X(f)|');

       
    %% Quitamos las portadoras sin informacion
    % Misma operacion que antes, nos quedamos desde NFFT-NDATA/2 hasta NDATA
    rx_ofdm_freq = rx_ofdm_freq(ceil((NFFT-Lsimb)/2)+(1:Lsimb),:);

    %% Estimador de canal
    % rx_ofdm_freq viene entre -fs/2 y fs/2 por tanto
    % H_est también lo estará

    % Sacamos los pilotos recibidos
    rx_pilots = rx_ofdm_freq(1:12:end, :);
    
    % Estimamos con los pilotos recibidos
    % estimacion de canal por simbolos (columnas)
    Hp_est = rx_pilots./pilots;

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
    
    figure();	
    stem(f_neg, H_est_dB);
    hold on;
    plot(f_neg, H_trunked,'r');
    title('Canal y valor de los pilotos');
    xlabel('f[MHz]');
    ylabel('|H(f)|');
    legend('pilotos en rx', 'canal');
    
    % Definimos intervalo de interpolacion
    x = [1:11].';

    % Definimos indice para los datos interpolados
    index = (1:12:Lsimb-1)+1;

    % Interpolamos los datos y los metemos en H_est
    for k = 1:length(Hp_est(:,1))-1
        H_est_data = (x./12) * Hp_est(k+1,:) + ((12-x)./12) * Hp_est(k,:);
        H_est(index(k):index(k)+10, :) = H_est_data;
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
    
    figure;
    plot(f_est,20*log10(abs(H_est(:,1))),'r', f_data,20*log10(abs(H_real)), 'b');
    title('Canal real H(dB) VS Canal estimado H_e_s_t(dB)');
    legend('|H_e_s_t(f)|','|H(f)|'); 
    xlabel('f[MHz]');
    ylabel('dB');

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
    
    figure;
    plot(f_rx_port/1e6,abs(rx_portadoras));
    title('Portadoras Ecualizadas');
    xlabel('f[MHz]');
    ylabel('|s_e_q(f)|');

    %% Quitamos los pilotos

    % Nos quedamos con los datos que estan
    % en las posiciones data_index definidas
    % antes como el vector en el que no estan
    % los pilotos
    rx_constel_data = rx_ofdm_freq(data_index, :);
    
    % Pasandolo a un vector de simbolos
    rx_constel_data = rx_constel_data(:);
    

    %% Dibujamos los simbolos recibidos
    figure;
    plot(rx_constel_data, 'xr');      
                        % Si vector es entero numero complejos plot
                        % los pinta en eje Re e Im, si C es real le
                        % añadimos una Im = 0 para que no de error
    grid;
    axis([-1.5 1.5 -1.5 1.5]);
                        % axis([Xmin Xmax Ymin Ymax]);
    title('Constelacion Recibida');
    xlabel('Re');
    ylabel('Im');

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
