load handel.mat % Recuperar la señal “y” en valores [-1 1]
k=8;                                 % Cantidad de bits para Cuantizar
 %Cuantizar a entero y expresión en binario
swing = (2^k-1)/2;                   % Señal simétrica
xq_int = round(y*swing+swing);       % Convertir a entero en [0 2^b-1]
xq_bin = de2bi(xq_int,k,'left-msb'); % Convertir entero a binario
xq_bin(100,:)
max(y)

%xq_bin = decimalToBinaryVector(xq_int,k,'MSBFirst'); %Opción 1
%xq_bin = decimalToBinaryVector(xq_int,k,'LSBFirst'); %Opción 2
[Valor1, My] = max(y); %My y my es la posicion donde se encuentra el valor 
[Valor2, my] = min(y);
decVal1 = binaryVectorToDecimal(xq_bin(My,:),'MSBFirst');
decVal2 = binaryVectorToDecimal(xq_bin(my,:),'MSBFirst');

realVal1 = (decVal1 - swing)/swing
realVal2 = (decVal2 - swing)/swing

clear all
%{
% Test Bench Configuration
frameLength = 1024;  
% Audio object for reading an audio file
fileReader = dsp.AudioFileReader('Counting-16-44p1-mono-15secs.wav','SamplesPerFrame',frameLength);
% Audio object for writing the audio device
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);
% Object for Visualization
scope = timescope('SampleRate',fileReader.SampleRate,'TimeSpanSource', 'property','TimeSpan', 2,'BufferLength',fileReader.SampleRate*2*2,'YLimits',[-1,1],'TimeSpanOverrunAction',"Scroll");


% Quantization process (Q)
k=16;                              % Cantidad de bits
swing = (2^k-1)/2;         %   Asumir señal en el rango [-1 1] y usar                    
% un rango simétrico
% Audio Stream Loop
while ~isDone(fileReader)                   %
signal = fileReader();                        %
xq_int = round(signal*swing+swing); % Convertir a enteros en el 
% rango [0 2^k-1] usando k bits 
xq = (xq_int-swing)/swing;     % Proceso inverso
scope([signal,xq])                  % Visualizacion
deviceWriter(xq);                    % Enviar la señal al driver de audio
end
release(fileReader)                         
release(deviceWriter)                      
release(scope) 
%}





load lena512.mat % https://www.ece.rice.edu/~wakin/images/
a=lena512;   % Lena en escala cargada tipo double
imshow(uint8(a)); %Casting uint8 bits para escala de grises
gscl=8;
an=a/(2^8-1); % Normalizar entre 0 y 1
%an = an + 0.1*rand(size(an)); Dithering effect
b=3;  % Cantidad de bits para representar
xq=round(an*(2^b-1)); %Cuantificar usando b bits;
xq=round(xq*(2^gscl-1)/max(max(xq))); % Normalizar al máximo
% para escala de grises
figure(2); imshow(uint8(xq)) % mostrar la figura
