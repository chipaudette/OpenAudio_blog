function [pD,f,h]=windowedFFTPlot(data,N,overlap,fs,plots,windowing);
%function [PSD,freq_Hz]=windowedFFTPlot(data,N,overlap,fs,plots,windowing);
%
%assumes data is real
%returns non-negative frequencies
%returns power per bin (positive freq bin...I foled neg freq energy into positive freqs)
%
%To plot dB/Hz instead of dB/bin:
%   PSD_per_Hz = PSD / ((fs/2) / size(PSD,1));
%
%
%normalizes out effect of windowing function
%normalizes out loss of power by removing negative frequencies
%
%summing pD should equal mean power of data
%
%
%see also: windowedFFT2.m, windowedFFTPlot_spectragram, windowedFFTPlot_phaseCoherence.m

if nargin < 6
    windowing=[];
    if nargin < 5
        plots=1;
    end
end

if (size(data,1)==1);data=data';end;

dataIn=data;
for Icol=1:size(dataIn,2)
    data=dataIn(:,Icol);

    data=data(1:2*floor(length(data)/2));  %make even number of samples
    [wD,wT,f]=windowedFFT2([1:length(data)]/fs,data,N,overlap,windowing);
    pD=wD.*conj(wD)./(N.^2);  %power per bin
    if size(pD,2) > 1  %added WEA 2012-08-29
        pD=mean(pD')';
    end
    
    %get positive freqs only
    f=f(1:N/2+1);
    %pD = pD(1:N/2+1); pD(2:end-1)=2*pD(2:end-1);   %scale to account for lost neg-freq power
    pD=[pD(1); pD(2:N/2)+pD(end:-1:(N/2+2)); pD(N/2+1)];  %add in the neg-freq power

    if (Icol==1)
        pD_out=pD;
    else
        pD_out(:,Icol)=pD;
    end
end
f=f(:);  %make into column vector
pD=pD_out;

h=[];
if (plots==1)
    h=semilogx(f,10*log10(pD));
    xlabel('Frequency (Hz)');
    ylabel('Power Spectral Density (dB/bin)')
end

