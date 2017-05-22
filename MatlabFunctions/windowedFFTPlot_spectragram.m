function [pD,wT,f]=windowedFFTPlot_spectragram(data,N,overlap,fs,plots,windowing);
%function [pD,wT,f]=windowedFFTPlot_spectragram(data,N,overlap,fs,plots,windowing);
%
%assumes data is real
%returns non-negative frequencies
%returns mean power per bin
%
%normalizes out effect of windowing function
%normalizes out loss of power by removing negative frequencies
%
%summing pD should equal mean power of data
%
%wT is time of the START of the data
%
%Example: [pD,wT,f]=windowedFFTPlot_spectragram(data,256,0.75,fs);
%
%To limit the color scaling: 
%           cl = get(gcf,'clim');
%           set(gcf,'Clim',cl(2)+[-100 0]);

if nargin < 6
    windowing=[];
    if nargin < 5
        plots=1;
    end
end

data=data(1:2*floor(length(data)/2));  %make even number of samples
[pD,wT,f]=windowedFFT2(fs,data,N,overlap,windowing); %NOT yet pD...just fft(data)
clear data

pD=pD.*conj(pD)./(N.^2);  %power per bin
%pD=median(pD')';
f=f(1:N/2+1);pD=pD(1:N/2+1,:); %get positive freqs only
pD(2:end-1,:)=2*pD(2:end-1,:);   %scale to account for lost neg-freq power

if (plots==1)
    imagesc(wT,f,10*log10(pD));
    set(gca,'Ydir','normal');
    xlabel('Time (sec)');
    ylabel('Frequency (Hz)');
    title('Power Spectral Density (dB/bin)')
    cl=get(gca,'Clim');set(gca,'Clim',cl(2)+[-100 0]);
end
%t=wT;

