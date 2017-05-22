function [A,fs] = loadWavAndDat(fName)

%loads the .wav file specified in by fName and scales it to be proper units
%(V)

%try
%    [wav,fs] = wavread(fName);  %older matlab
%catch
    [wav,fs] = audioread(fName); %newer matlab
%end

fName = [fName(1:end-4) '.dat'];
scaleFactors = load(fName);

for ii=1:1:size(wav,2)

A(:,ii) = wav(:,ii).*scaleFactors(ii,1) + scaleFactors(ii,2);

end

% figure;plot(B)