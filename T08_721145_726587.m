load lena512.mat
%lenarec=lena512(252:379,318:445); 128x128
%lenarec=lena512(252:338,318:404);%87x87
lenarec=lena512(252:296,318:362); %45x45
figure(1);
imshow(uint8(lenarec))
title("Lena's eye");
b = de2bi(lenarec,8,'left-msb'); % Convert the samples from uint8 to binary
b = b';     
bits = b(:);

bits2send = bits';
Fs= 96000;
mp= 10;
%No_bits= 8712;
Baud_rate= Fs/mp   %Symbols per second
Bit_rate=Baud_rate % bits/s
Ts=1/Fs;
% The bit rate is Rb= Rs= Fs / mp, because 1 bit= 1 symbol and  every symbol has mp
% samples per bit


n= 0:(mp-1);
w = pi/mp;
hs = sin(w*n);

pnrz=ones(1,mp);

s1=bits;
s1(s1==0)=-1;
s=zeros(1,numel(s1)*mp);
s(1:mp:end)=s1; %Impulse train
stem(s(1:mp*16))

xPNRZ_hs=conv(hs,s); %Pulse half sine
xPNRZ=conv(pnrz,s); %Pulse rectangular




figure();
pow = sum(xPNRZ_hs.^2)/numel(xPNRZ_hs);
pow_Deseada = 1;
xPNRZ_hs = sqrt(pow_Deseada/pow)*xPNRZ_hs;
%eyediagram(xPNRZ_hs,2*mp);
figure();
%plot(xPNRZ(1:mp*16))
pow = sum(xPNRZ.^2)/numel(xPNRZ);
pow_Deseada = 1;
xPNRZ = sqrt(pow_Deseada/pow)*xPNRZ;
%eyediagram(xPNRZ,2*mp);



orden=60;     % Orden del Filtro 
f=   [0 0.6 0.6 1];  % Vector de Frecuencias
m= [1 1 0 0]; % Vector de Magnitudes 
f1 = fir2(orden,f,m);  % Coeficientes del Filtro usando FIR2( ) 
%fvtool(f1);    
 
xPNRZ_filtrado_f1 = conv(xPNRZ_hs,f1);
%eyediagram(xPNRZ_filtrado_f1,2*mp);

xPNRZ_filtrado_f2 = conv(xPNRZ,f1);
%eyediagram(xPNRZ_filtrado_f2,2*mp);


pow1 = sum(xPNRZ_filtrado_f1.^2)/numel(xPNRZ_filtrado_f1);
pow_Deseada = 1;
xPNRZ_filtrado_f1 = sqrt(pow_Deseada/pow1)*xPNRZ_filtrado_f1;

pow2 = sum(xPNRZ_filtrado_f2.^2)/numel(xPNRZ_filtrado_f2);
pow_Deseada = 1;
xPNRZ_filtrado_f2 = sqrt(pow_Deseada/pow2)*xPNRZ_filtrado_f2;


%PNoise = N02 * sum(h.*h) * Ts % Observe que PNoise es un escalar 
PNoise = 0.03125;
PNoise = PNoise*mp;

Noise = sqrt(PNoise) * randn(1,numel(xPNRZ_filtrado_f1)); 
var(Noise) % Debe ser igual al valor de PNoise considerado
SNR_dB = 10*log10(1 / PNoise);

Noise2 = sqrt(PNoise) * randn(1,numel(xPNRZ_filtrado_f2)); 
var(Noise2) % Debe ser igual al valor de PNoise considerado
SNR_dB_2 = 10*log10(1 / PNoise);


Rx_Signal_AWGN_hs = xPNRZ_filtrado_f1 + Noise ; 
Rx_Signal_AWGN_rec = xPNRZ_filtrado_f2 + Noise2 ; 

%ejercicio 2
Match_filter1 = fliplr(hs);
Match_filter2 = fliplr(pnrz);

Const11 =conv(Rx_Signal_AWGN_hs,Match_filter1)/mp;
Const22 =conv(Rx_Signal_AWGN_rec,Match_filter2)/mp;


delay_signal = orden/2 + numel(pnrz)/2; %calculate the signal delay, channel delay + match filter delay
delay_signal_hs = orden/2 + numel(hs)/2; %calculate the signal delay, channel delay + match filter delay
start_recovery_count = delay_signal + mp/2;
start_recovery_count_hs = delay_signal_hs + mp/2;

PNRZ_recovery_rec = Const22(start_recovery_count:mp:end);
PNRZ_recovery_hs = Const11(start_recovery_count:mp:end);

PNRZ_recovery_rec = PNRZ_recovery_rec(1:numel(bits2send));
PNRZ_recovery_hs = PNRZ_recovery_hs(1:numel(bits2send));

bits_RX_PNRZ_1 = zeros(1,numel(bits2send));
bits_RX_PNRZ_2 = zeros(1,numel(bits2send));

xPNRZ_f_m1 = PNRZ_recovery_hs;
xPNRZ_f_m2 = PNRZ_recovery_rec;

bits_RX_PNRZ_1(xPNRZ_f_m1 > 0) = 1;   %Umbral +
bits_RX_PNRZ_2(xPNRZ_f_m2 > 0) = 1;   %Umbral +

xPNRZ_BER_1_hs = (sum(xor(bits2send,bits_RX_PNRZ_1))/numel(bits2send)) * 100
xPNRZ_BER_2_rec = (sum(xor(bits2send,bits_RX_PNRZ_2))/numel(bits2send)) * 100

%bertool()



