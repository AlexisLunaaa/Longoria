% se al muy similar a la anal gica��
% Cosenoidal de frecuencia f Hz
f=10;
Ts = 1/1000;
t = 0:Ts:1;
x = cos(2*pi*t*f);
% se al con muestreo natural 19 veces m s lento (53Hz)��
tm = t(1:19:end);
xm = cos(2*pi*tm*f);
% se al muestreada con sample-and-hold�
tsh = 19;
xs = zeros(1,numel(t));
for i=1:numel(t)
    if( rem(i,tsh)==1 )
        tmp = x(i);
    end
    xs(i) = tmp;
end
% Proceso de Cuantificaci n�
M = 256;
int = (max(xs)-min(xs))/M;
m = (min(xs)+int/2):int:(max(xs)-int/2);
xq = zeros(1,length(t));
for i=1:length(t)
    [tmp, k] = min(abs(xs(i)-m));
    xq(i) = m(k);
end
% diferencia
xd = xs - xq;
% graficas
sgtitle('M=256')
figure(1)
subplot(4,1,1);
plot(t,x)  %analog signal
title('Figure 1: analog signal & natural sampling');
hold on
stem(tm,xm,'r','filled') %natural sampling
figure(2)
subplot(4,1,2);
plot(t,xs)  %sample and hold
title('Figure 2: sample and hold');
figure(3)
subplot(4,1,3);
plot(t,xq) %quantified
title('Figure 3: quantified');
figure(4)
subplot(4,1,4);
plot(t,xd) %difference
title('Figure 4: difference');
%Potencia de la se al: �
Px=x*x'/numel(x); %var(x)
ex = xs-xq; %Forma 1
%%*****************Forma 2
%  b=log2(M);
%  xq= round(x*(2^(b-1)))/(2^(b-1)); %Se al Cuantizada�
%  ex = x-xq; 
%*************************************
Pn=ex*ex'/numel(ex);
SQNR_xdB = 10*log10(Px/Pn) %Simulado
SQNR_Teorico2= 6.02*(log2(M)) + 1.76 % Para una se al sinusoidal