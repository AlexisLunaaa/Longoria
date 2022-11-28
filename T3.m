%% Ejemplo
%{
t = [0 0.1 0.2 0.3 0.4 0.5]; 
 
%primero inicializamos la señal a cero con: 
 
x = zeros(1,numel(t)); 
 
%y después encontramos los índices donde vale 1: 
 
x(find( (t>=0.2) & (t<=0.4) )) = 1; 
%}
Fs = 100;
t = 0:1/Fs:1;
x = zeros(1,numel(t));
x(find( (t>=0.4) & (t<=0.6) )) = 1;
plot (t,x)
title("Pulso cuadrado 0.4 -> 0.6 segundos")
wvtool(x)

%4.
%x2 = zeros(1,numel(t));
%x2(find( (t>=0) & (t<=0.2) )) = 1;
%plot (t,x2)
%title("Pulso cuadrado 0.0 -> 0.2 segundos")
%wvtool(x2)


%% Ejercicio2
x3 = zeros(1,numel(t));
x3(find( (t>=0.2) & (t<=0.4) )) = 1;
x3(find( (t>=0.7) & (t<=0.9) )) = 1;
plot (t,x)
title("Pulsos cuadrados 0.2 -> 0.4 y 0.7 -> 0.9 segundos")
wvtool(x) 

%% Ejercicio3 
x4 = zeros(1,numel(t));
x4(find( (t>=0.2) & (t<=0.4) )) = 1;
x4(find( (t>=0.7) & (t<=0.9) )) = -1;


%% Ejercicio4
x5 = zeros(1,numel(t));
x6 = zeros(1,numel(t));
x7 = zeros(1,numel(t));
x8 = zeros(1,numel(t));

x5(find( (t>=0.45) & (t<=0.55) )) = 1;
x6(find( (t>=0.475) & (t<=0.525) )) = 1;
x7(find( (t>=0.3) & (t<=0.7) )) = 1;
x8(find( (t>=0.2) & (t<=0.8) )) = 1;
wvtool(x5)
wvtool(x6)
wvtool(x7)
wvtool(x8)
