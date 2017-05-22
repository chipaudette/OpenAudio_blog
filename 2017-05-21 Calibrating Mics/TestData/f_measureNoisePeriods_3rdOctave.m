function [sig_in_dB,sig_out_dB,freq_Hz] = f_measureNoisePeriods_3rdOctave(wav,fs_Hz,n_test,t_offset_sec,t_period_sec,t_win,norm_fac);

sig_in_dB=[];sig_out_dB=[];
freq_Hz = 125*2.^([0:1/3:7]);

for Iband = 1:length(freq_Hz);

    %filter to 3rd octave band
    N=3;  %filter order, normally 3
    [b,a]=oct3dsgn(freq_Hz(Iband),fs_Hz,N);
    foo_wav = filter(b,a,wav);
 
    %get ave RMS every noise period
    for Itest=1:n_test;
        t_win_foo = -t_offset_sec+(Itest-1)*t_period_sec + t_win;
        inds = round(t_win_foo*fs_Hz);inds(1)=inds(1)+1;
        excerpt = foo_wav(inds(1):inds(2),:);
        excerpt = excerpt - ones(size(excerpt,1),1)*mean(excerpt); %remove DC
        
        %compute RMS and convert to dB
        sig_in_dB(Iband,Itest) = 10*log10(mean((excerpt(:,1)/norm_fac(1)).^2));
        sig_out_dB(Iband,Itest) = 10*log10(mean((excerpt(:,2)/norm_fac(2)).^2));
    end
end