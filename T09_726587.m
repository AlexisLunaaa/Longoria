%ejercicio 1.1
Fs = 8000; 
B = 1000;
Rb = 2000;
D = 10; %Determine el valor de β. 
Rs = Rb;
Tp = 1/Rb
Ts = 1/Fs
%mp muestras son Tp segundos mp = Tp/Ts
mp = Tp/Ts
%Rs = 2B/(1+r)
r = (2*B/Rs) - 1
beta = r
energy = Tp;
Type = 'rc';
pulso_base = rcpulse(beta, D, Tp, Ts, Type, energy);

%ancho de banda = frecuancia en samples a los -2db *(Fs/2)
ancho_de_banda = 0.25 * (Fs/2)

%ejercicio 1.2
Fs = 8000; 
B = 1000;
beta = 0.2;
D = 10;%determine el valor de Rb
Rs = (2*B)/(1+beta)
%%Rb = ((2*B)/Rs)-1
Tp = 1/Rs
Ts = 1/Fs
energy = Tp;
Type = 'rc';
res = Tp/Ts
ancho_de_banda = 0.4 * (Fs/2)
mp=5;
Tpnew=mp*Ts
Rsnew=1/Tpnew;
Bocupado=((1+beta)*Rsnew)/2
pulso_base2 = rcpulse(beta, D, Tpnew, Ts, Type, energy);

%ejercicio 1.3
Fs = 4000; 
Rb = 2000;
beta = 0.8;
D = 6;%determine el valor de B
Tp = 1/Rb; 
Ts = 1/Fs;
energy = Tp;
type = 'rc';
B=(Rb*(beta+1))/2
pulso_base3 = rcpulse(beta, D, Tp, Ts, Type, energy);


%ejercicio 2
wvtool(pulso_base)
wvtool(pulso_base2)
wvtool(pulso_base3)

%ejercicio3
beta = 0;
Fs = 1000;
Tp = 1/100;
D = 10;
Rs = 2000;
Ts = 1/Fs;
mp = Tp/Ts; %mp
energy = Tp;
type = 'rc';

pbase = rcpulse(beta,D,Tp,Ts,type,energy);

%3.1
bit_sequence = [1 0 1 1 0 0 1 1 1 1 1];
PNRZ_map = zeros(1,numel(bit_sequence)*mp);

counter = 0;
for i= 0 : numel(bit_sequence)-1
    if bit_sequence(i+1) == 0
        value = -1;
    else
        value = 1;
    end
    PNRZ_map(counter*i+1) = value;
    counter = mp;
end
Polar_NRZ_signal = conv(pbase ,PNRZ_map);
figure();
plot(Polar_NRZ_signal);
title('Transmitted signal');

%ejercicio 4. Etapa de transmision
load lena512.mat 
beta = 0;
Fs = 96000;
Ts = 1/Fs;
Rs = 9600;
D = 10;
Rb = Rs;
Tp = 1/Rb; 
energy = sqrt(Tp);
type = 'rc';
mp = round(Tp/Ts); %mp

SRRC = rcpulse(beta,D,Tp,Ts,type,energy);

lenarec=lena512((284-127):284, (350-127):350); 

b=de2bi(lenarec,8); 
b=b'; 
bits=b(:);   
bit_pixels = b(1:128*128*8);

bit_pixels_PNRZ = zeros(1,numel(bit_pixels)*mp);


counter = 0;
for i= 0 : numel(bit_pixels)-1
    if bit_pixels(i+1) == 0
        value = -1;
    else
        value = 1;
    end
    bit_pixels_PNRZ(counter*i+1) = value;
    counter = mp;
end

SRRC_PNRZ_signal = conv(bit_pixels_PNRZ, SRRC);
plot(SRRC_PNRZ_signal(51:51+mp*16));


start = round(numel(SRRC)/2);
sampled_signal = SRRC_PNRZ_signal(start:mp:end);


scatterplot(sampled_signal);
title('Bits plot');
figure();
pwelch(SRRC_PNRZ_signal,500,300,500,Fs,'power');
title('PSD bit stream');
%eyediagram(SRRC_PNRZ_signal, 3*mp);

%Ejercicio 5. ETAPA DE RECEPCIÓN 
f=[0 0.6 0.6 1];
m=[1 1 0 0];
ford=60;
filter_1 = fir2(ford,f,m);

signal_filtered = conv(filter_1,SRRC_PNRZ_signal);
match_f = fliplr(SRRC);
recover_signal = conv(match_f,signal_filtered);

start_recovery = ford/2 + start;
recovery_signal = recover_signal(start_recovery:mp:end);
figure();
pwelch(recover_signal,500,300,500,Fs,'power');
title('PSD bit stream');
%eyediagram 
%eyediagram(recover_signal, 3*mp);
scatterplot(recovery_signal);
treshhold = 0;

PNRZ_recovery_bits_rec = zeros(1,numel(bit_pixels));
PNRZ_recovery_bits_rec((recovery_signal > treshhold)) = 1; 

bits_error_PNRZ = xor(bit_pixels, PNRZ_recovery_bits_rec(1:numel(bit_pixels)));
error_PNRZ = sum(bits_error_PNRZ);
Bit_error_rate_PNRZ = (error_PNRZ/numel(bit_pixels)) * 100





