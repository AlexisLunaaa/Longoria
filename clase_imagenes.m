load lena512.mat 
imshow(uint8(lena512)) 
lenarec=lena512(252:284,318:350); 
imshow(uint8(lenarec)) 
b = de2bi(lenarec,8,'left-msb');
b=b'; 
bits=b(:);   % Vector de bits concatenado 
%% Reconstruir la imagen 

bitsM = reshape(bits,8,1089);
bitsM = bitsM';
decval = bi2de(bitsM,'left-msb');
lenaRS = reshape(decval, size(lenarec));
imshow(uint8(lenaRS))