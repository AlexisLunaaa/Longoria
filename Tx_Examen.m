
%% fase 2
preamble= [1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0]' ;
SFD= [1 0 1 0 1 0 1 1]'; 
DSA = de2bi(uint8('Practica II FASE II: NoExp1 y NoExp2'),8,'left-msb'); 
DSA = reshape(DSA',numel(DSA),1); 
load lena512.mat; img = uint8(lena512); 
img = img(248:247+33,245:244+45,1); % Image size= 4(UDE1) x 4(UDE2) pixels 
imshow(img);  % Where UDE =Último Dígito Expediente 
size_img=de2bi(size(img),16,'left-msb') 
header= [size_img(1,:) size_img(2,:)]'; 
payload = de2bi(img,8,'left-msb');  % Puede ser right-msb 
payload = payload'; 
payload = payload(:); 
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
%%[pbase ~] = rcpulse(beta, D, Tp, Ts, type, E);    % Pulse Generation 
pbase = ones(1,mp);

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

