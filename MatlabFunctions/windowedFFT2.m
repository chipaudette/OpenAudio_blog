function [windowedData,windowedTime,freqs]=windowedFFT2(t,data,nwindow,overlap,windowing);
%Function: [windowedFFTData,windowedTime,freqs]=windowedFFT2(t,data,nwindow,overlap,windowing);
%overlap is a number from 0 to 1;
%
%scales output data to remove power loss due to windowing function
%


if (nargin < 5)
  windowing=[];
end
  
[data,start_ind,Noverlap,window]=blockData2(data,nwindow,overlap,windowing);
%win_pow = mean(window).^2;  %changed to this form on 2012-05-21
win_pow = mean(window.^2);  %changed this on 2013-03-27
windowedData=fft(data)./sqrt(win_pow);
clear data

if (length(t)==1)
    fs = t;
    windowedTime = (start_ind-1)/fs;
else
    windowedTime=t(start_ind);
    fs=median(1./diff(t));
    clear t
end
%freqs=[0:fs/nwindow:fs-fs/nwindow];
freqs=[0:1/nwindow:1]*fs;
freqs=freqs(1:nwindow);

%freqs=[0:1/(nwindow-1):1];
%freqs=[0:1/(nwindow/2+1):1]*0.5;
%freqs=[freqs 1-freqs(2:end-1)];



