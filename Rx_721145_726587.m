%****** Receiving Sine waves********%
Fs=96000; Nb=16;Chs=1; 
recObj = audiorecorder(Fs, Nb, Chs); 
get(recObj); 
disp('Start speaking.') 
recordblocking(recObj, 5); 
disp('End of Recording.'); 
play(recObj); % Play back the recording. 
% Store data in double-precision array. 
myRecording = getaudiodata(recObj); 
% Plot the waveform. 
plot(myRecording); 
title('Recording plot');
% Power Spectrum Densitiy: 
figure();
pwelch(myRecording,500,300,500,'one-side','power',Fs) 



%% fase 2
preamble= [1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0]' ;
SFD= [1 0 1 0 1 0 1 1]'; 
DSA = de2bi(uint8('Practica II FASE II: NoExp1 y NoExp2'),8,'left-msb'); 
DSA = reshape(DSA',numel(DSA),1); 
load lena512.mat; img = uint8(lena512); 
img = img(248:247+88,245:244+100,1); % Image size= 4(UDE1) x 4(UDE2) pixels 
imshow(img);  % Where UDE =Último Dígito Expediente 
size_img=de2bi(size(img),16,'left-msb');
header= [size_img(1,:) size_img(2,:)]'; 
payload = de2bi(img,8,'left-msb');  % Puede ser right-msb 
payload = payload'; 
payload = payload(:); 
bits2Tx = [preamble; SFD; DSA; header; payload]; 



%EL RECEPTOR TAMBIEN CONOCE EL PULSO FORMADOR
%modificar el valor de B en 4000 y12000 para los diferentes ejercicios
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


%%
%forma2:

%Fs=96e3; sec=5;  % Time duration of the whole communication including the silence 
%recObj = audiorecorder(Fs,16,1); 
%disp('Start speaking'); 
%recordblocking(recObj, sec); 
%disp('End of Recording'); 
%Rx_signal = getaudiodata(recObj); 

%forma1: se puede utilizar un archivo WAV o escuchar la señal directamante y guardarla
filename= 'Lena88x100.wav'; 
info=audioinfo(filename); 
b = info.BitsPerSample; 
Fs_audio =  info.SampleRate; 
%Fs_audio =  96e3; 
%sec = 1; start = 0.5; 
%samples = [start*Fs_audio,(sec+start)*Fs_audio-1]; 
[Rx_signal,Fs_audio] = audioread(filename);
plot(Rx_signal)

threshold = 0.1;                            % Detecting the channel energization 
start = find(abs(Rx_signal)> threshold,3,'first'); % Initial 
stop  = find(abs(Rx_signal)> threshold,1,'last');  % End 
Rx_signal = Rx_signal (start:stop); 

match = fliplr(pbase);%el pulso formador tambien lo conoce el receptor
Rx_signal_match = conv(match, Rx_signal);
plot(Rx_signal_match(1:500)); % To view preamble, SFD, DSA and header bits
eyediagram(Rx_signal_match(1:3000), mp*3);
figure();
pwelch(Rx_signal_match,500,300,500,'one-side','power',Fs)
%figure();
%plot(Rx_signal_match(1:mp*128))
%% Detector de preambulo, SFD, SDA justo despues del match filter 

%cambiar el inicio del preambulo dependiendo de cual B se esta utilizando
start_preamble = 94;
preamble = sign(Rx_signal_match(start_preamble:mp:56*mp+(start_preamble-1)));
preamble = (preamble + 1)/2
%preamble'

start_sfd = 56*mp + start_preamble;
sfd = sign(Rx_signal_match(start_sfd:mp:56*mp+(start_preamble-1)+8*mp));
sfd = (sfd + 1)/2
%sfd'

start_sda = start_sfd +8*mp;
dsa = sign(Rx_signal_match(start_sda:mp:56*mp+(start_preamble-1)+8*mp+288*mp));
dsa = (dsa + 1)/2
%sda'


%% sincronizacion de simbolo diagrama de ojo (en el punto mas abierto) y pwelch

symbolSync=comm.SymbolSynchronizer('TimingErrorDetector','Early-Late (non-data-aided)','SamplesPerSymbol',mp);
rx_sync = symbolSync(Rx_signal_match);
release(symbolSync);
figure();
stem(rx_sync(1:128))
%%
delay = round(numel(pbase)/2);
eyediagram(rx_sync(delay+1:end-delay),2); 
figure
pwelch(rx_sync,500,300,500,Fs,'power')

%% Conversion de la señal a la salida del match filter a bits

start = 109; % Starting medition point 
Rx_sam = Rx_signal_match(start:mp:end); % Sample every mp
bits_Rx = zeros(1,numel(Rx_sam));
bits_Rx(Rx_sam >= 0) = 1;
bits_Rx(Rx_sam < 0) = 0;
plot(bits_Rx(1:128)); 
bits_Rx = bits_Rx(1:numel(bits2Tx));
bits_Rx = bits_Rx';

%% Detector de preambulo, SFD, SDA, Header y Payload con la señal en bits

% Creación del objeto
preamble_detect = comm.PreambleDetector(preamble,'Input','Bit');
%Deteccion del preambulo. 
idx = preamble_detect(bits_Rx(1:128)) % Ventana de 128 bits

%Definición de los tamaños de cada elemento conocido de la trama en bits
preambleSize = 56;
SFDSize = 8;
DSASize = 288;
headerSize = 32;
% Una vez que encuentra el índice, se descartan los “bits basura”
% Una forma de hacerlo es la siguiente:
bits_Rxp= bits_Rx(idx+1-numel(preamble):end);
%el error debe dar 0, estos ignifica que todos los bits
%de preambulo son iguales
error = sum(xor(bits_Rxp(1:56), preamble))/numel(bits_Rxp(1:56))

preamble_rx = bits_Rxp(1:preambleSize);

%SFD y DSA
next_start = preambleSize + 1;
next_end = next_start + SFDSize - 1;
SFD_rx = bits_Rxp(next_start: next_end);
error = sum(xor(bits_Rxp(next_start:next_end), SFD))/numel(bits_Rxp(next_start:next_end))

next_start = next_end + 1;
next_end = next_start + DSASize - 1;
DSA_rx = bits_Rxp(next_start: next_end);
error = sum(xor(bits_Rxp(next_start:next_end),  DSA))/numel(bits_Rxp(next_start:next_end))

%Header
next_start = next_end + 1;
next_end = next_start + headerSize - 1;
header_rx = bits_Rxp(next_start: next_end);
error = sum(xor(bits_Rxp(next_start:next_end),  header))/numel(bits_Rxp(next_start:next_end))

%Get size
header_reshaped = reshape(header_rx,16,2*1);
size1 = bi2de(header_reshaped(:,1,:)', "left-msb");
size2 = bi2de(header_reshaped(:,2,:)', "left-msb");

%Get Lena
next_start = next_end + 1;
next_end = next_start + (size1 * size2 * 8) - 1;
payload_rx = bits_Rx(next_start: next_end);

BER = sum(xor(payload, payload_rx))/numel(payload)

%% Reconstruccion de imagen
Mbits=reshape(payload_rx,8,size1 * size2);
vint=bi2de(Mbits','left-msb');
Mint=vec2mat(vint,size1,size2);
Mint=Mint';
figure
imshow(uint8(Mint))
%% Reconstruccion de audio
%5. Construcción y escritura del archivo de audio
audioValues = vec2mat(bitsVector,8); % Obtain Bytes
audioValues = bi2de(audioValues); % Bin2Dec conversion
rxAudioId = fopen('rx_audio.opus','w'); %File ID
fwrite(rxAudioId,audioValues); % Write the file

