function [A,fs] = loadWavAndDat(fName)

%loads the .wav file specified in by fName and scales it to be proper units
%(V)

%try
%    [wav,fs] = wavread(fName);  %older matlab
%catch
    [wav,fs] = audioread(fName); %newer matlab
%end

fName = [fName(1:end-4) '.dat']; %gets rid of .wav and replaces it with .dat
scaleFactors = load(fName); %dat files consist of a 1 by 2 matrix (2 values)

for ii=1:1:size(wav,2)

A(:,ii) = wav(:,ii).*scaleFactors(ii,1) + scaleFactors(ii,2); %applies scaling values to each point in the wav file

end

% figure;plot(B)