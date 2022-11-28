clear all;
%****** Generating Sine waves********%
Fs = 96000; % Sampling Fs 
Ts = 1/Fs;
F1 = 5000;  % SIN_1 frequency
F2 = 10000; % SIN_2 frequency
T = 10;      % Duration
t = 0:Ts:(T-Ts);    % Vector time

sin5k  = sin(2*pi*F1*t); 
sin10k = sin(2*pi*F2*t);

%%
%***** Transmiting signals ********%
soundsc(sin5k,Fs);
soundsc(sin10k,Fs);
%%
%sendign a pulse 
soundsc( [zeros(1,Fs) 1 zeros(1,Fs)], Fs );

%%
%Sending AWGN 
xa = ones(1,Fs*5);
xa_noised  = awgn(xa,10);
plot(xa_noised);

soundsc(xa_noised,Fs);

%%
%Generate a Power Signal: Chirp Signal for example
start=0;
end_c=5;
t = start:1/Fs:end_c;
fo = 20;
f1 = 20e3;
y = chirp(t,fo,end_c,f1,'linear');
figure(1)
pwelch(y,500,300,500,'one-side','power',Fs)
plot(y);

%sending signal
soundsc(y,Fs);

%% fase 2


%4. Lectura de archivos OPUS
filename = 'Radioactive2segOpus.opus';
song = fopen(filename,'r'); % Read only
songV = fread(song);
fclose(song);
songV = uint8(songV);
size_audio=de2bi(size(songV),16,'left-msb') 
b = de2bi(songV,8); % Double to binary number
b = b'; 
bits_audio = b(:); % Arrange to a single vector
%% 

%lectura de imagen 

preamble= [1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0]' ;
SFD= [1 0 1 0 1 0 1 1]'; 
DSA = de2bi(uint8('Practica II FASE II: NoExp1 y NoExp2'),8,'left-msb'); 
DSA = reshape(DSA',numel(DSA),1); 
%load lena512.mat; img = uint8(lena512); 
%img = img(248:247+88,245:244+100,1); % Image size= 4(UDE1) x 4(UDE2) pixels 
%imshow(img);  % Where UDE =Último Dígito Expediente 
%size_img=de2bi(size(img),16,'left-msb') 
%header= [size_img(1,:) size_img(2,:)]'; 
header= [size_audio(1,:) size_audio(2,:)]'; 
%payload = de2bi(img,8,'left-msb');  % Puede ser right-msb 
%payload = payload'; 
%payload = payload(:); 
payload = bits_audio
bits2Tx = [preamble; SFD; DSA; header; payload]; 


%%
%transmisor 
Fs      =   96e3;              % Samples per second  
Ts      =   1/Fs;              % Sampling period 
beta    =   0.25;              % Roll-off factor 
B       =   4000;              % Bandwidth available 
Rb      =   2*B/(1+beta);      % Bit rate = Baud rate 
mp      =   ceil(Fs/Rb)        % samples per pulse 
Rb      =   Fs/mp;             % Recompute bit rate 
Tp      =   1/Rb;              % Symbol period 
B       =   (Rb*(1+beta)/2)    % Bandwidth consumed 
D       =   10;                % Time duration in terms of Tp 
type    =   'srrc';            % Shape pulse: Square Root Rise Cosine 
E       =   Tp;                % Energy 
[pbase ~] = rcpulse(beta, D, Tp, Ts, type, E);    % Pulse Generation 


s1=int8(bits2Tx);
s1(s1==0)=-1;
s=zeros(1,numel(s1)*mp);
s(1:mp:end)=s1; %Impulse train

xPNRZ=conv(pbase,s); 

pulse_time = numel(pbase)/Rb
pulse_train_time = numel(bits2Tx)/Rb
eyediagram(xPNRZ,mp*2);

silence_time = zeros(1,(Fs/2));
%paso 9 
soundsc( [silence_time xPNRZ], Fs );
