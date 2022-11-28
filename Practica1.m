%Escoger un archivo en formato WAV/Fla y leerlo
filename= 'Radioactive.wav'; 
info=audioinfo(filename); 
b = info.BitsPerSample; 
Fs_audio = info.SampleRate; 
sec = 10; start = 5; 
samples = [start*Fs_audio,(sec+start)*Fs_audio-1]; 
[x,Fs_audio] = audioread(filename,samples); 
%conertir el audio a Mono
xMono = (x(:,1) + x(:,2))/2;

%Filtrar la señal a 15 kHz 
B = 15e3; 
fc = B / (Fs_audio/2);  
fc_15KHz = [0 fc fc 1]; 
m = [1 1 0 0]; 
orden = 60; 
LPF_15KHz = fir2(orden, fc_15KHz, m); 
%fvtool(LPF_15KHz, 'Analysis', 'impulse'); 
xa = filter(LPF_15KHz, 1, xMono); 

%Normalizar la potencia a 1 Watt 
pot = sum(xa.*xa)/numel(xa); 
xa = xa/sqrt(pot); 
P_signal = var(xa); % Verificar la Potencia 
yMax=max(xa);
yMin=min(xa);

%encontrar la potencia del del ruido a la salida del filtroreceptor
B =15e3  ; % Ancho de Banda del filtro receptor 
N0 = 1./(B.*10.^(0:0.3:3));   % Vector PSD del ruido 
P_noise = B*N0;               % Vector de Pot del Ruido Filtrado  
P_noise_dB = 10.*log10(P_noise); % Pot. Ruido en Decibeles 
SNR_A = P_signal ./ P_noise;    % Relacion Señal a Ruido 
SNR_A_dB = 10*log10(SNR_A);     % SNR en dB 


for i=1:numel(N0)
P_noise(i)%potencia del ruido
SNR_A(i)%SNR
xa_noised = awgn(xa,SNR_A_dB(i)); % Función awgn de Matlab, generar y sumar ruido
xa_noised = filter(LPF_15KHz, 1, xa_noised); %Filtrar la señal distorsionada con el LPF de 15 KHz  
a_noised = normalize(xa_noised, 'norm', Inf); % Scale [-1,1]; 
filename = strcat('AnalogSignal', num2str(i), '_', num2str(round(SNR_A_dB(i)), 4), 'dB','.flac'); 
audiowrite(filename, xa_noised, Fs_audio ); 
end



%Transmisión digital. 
k=16;
swing = (2^k-1)/2;
xq_int = round(xMono*swing+swing);        % Convertir a entero en [0 2^b-1]
xq_bin = de2bi(xq_int,k,'left-msb'); % Convertir entero a binario
bits = xq_bin';
bits = bits(:);

%Receptor
bits_Rx = bits;
SNR_D_dB=50;
Mbits = reshape(bits_Rx,k, []);
int_Rx = bi2de(Mbits','left-msb');
xD = (int_Rx-swing)/swing; % Proceso inverso usando int_Rx Convertir a decimal
filename = strcat('P1_DigSignal', '_', num2str(round(SNR_D_dB), 4),'.flac'); 
audiowrite(filename, xD, Fs_audio ); 


%Diseñar el pulso SRRC con 
beta = 0.35;  
D = 6;
Fs = 96000;
Ts=1/Fs;
B = 15e3;
Rb = (2*B)/(1+beta);%tasa de bit Rb maxima
Tp = 1/Rb;
mp=ceil(Tp/Ts);%este es el numero de muestras por pulso

Tp_recalculado = mp*Ts;%con el nuevo mp se debe recalcular el Tp
Rb_new = 1/Tp_recalculado;%se debe recalcular el Rb con el nuevo Tp

energy = Tp;
Type = 'rc';

%generamos pulso base
pulso_base = rcpulse(beta, D, Tp_recalculado, Ts, Type, energy);
wvtool(pulso_base);

%tren de pulsos con el codigo de linea PNRZ
pnrz=ones(1,mp);
s1=bits;
s1(s1==0)=-1;
s=zeros(1,numel(s1)*mp);
s(1:mp:end)=s1; %Impulse train
xPNRZ=conv(pnrz,s); %Pulse train

%normalizamos el tren de pulsos para que tenga potencia unitaria
pow = sum(xPNRZ.^2)/numel(xPNRZ);
xPNRZ=xPNRZ/sqrt(pow);
P_signal_PNRZ=var(xPNRZ);     %Verificar la Potencia 
yMax=max(xPNRZ);
yMin=min(xPNRZ);
soundsc(xPNRZ);

% Agregar ruido
N0=1./(B.*10.^(0:0.3:3));        % Vector PSD del ruido 
P_noise=B*N0;                    % Vector de Pot del Ruido Filtrado  
P_noise_dB=10.*log10(P_noise);   % Pot. Ruido en Decibeles 
SNR_A=P_signal./P_noise;         % Relacion Señal a Ruido 
SNR_A_dB=10*log10(SNR_A);        % SNR en dB 


delay=(D*mp)/2;
delay_filter=orden/2;
h=pulso_base;


bits_RX_PNRZ_1 = zeros(1,numel(bits));

for i=1:numel(P_noise)
    noise=sqrt(P_noise(i))*randn(size(xPNRZ)); %Muestras de ruido del tamaño del vector del tren de pulsos
    xPNRZ_noised=xPNRZ+noise; %agregamos el ruido
    xPNRZ_filtered=filter(LPF_15KHz,1,xPNRZ_noised);%filtrar el tren de pulsos mas ruido con el LPF
    xPNRZ_match=conv(h,xPNRZ_filtered);
    %retardo de la señal, retardo del match filter y retardo del canal
    xPNRZ_sampled=xPN[RZ_match(((2*delay)+delay_filter+1) : mp : end);
    xPNRZ_sampled=normalize(xPNRZ_sampled,'norm',Inf); % Scale [-1,1]; 
    xPNRZ_sampled=abs(xPNRZ_sampled);
    xPNRZ_f_m1 = xPNRZ_sampled;
    %convertir las muestras a bits con el codigo de linea PNRZ
    bits_RX_PNRZ_1(xPNRZ_f_m1 > (max(xPNRZ_sampled)/2)) = 1;  
    int_Rx=reshape(bits_RX_PNRZ_1,16,[]);
    int_Rx=bi2de(int_Rx','left-msb');
    Mono_Rx=(int_Rx-swing)/swing;
    filename=strcat('DigitalSignal',num2str(i),'_',num2str(round(SNR_A_dB(i)),4),'dB','.flac'); 
    audiowrite(filename,Mono_Rx,Fs_audio);
end

