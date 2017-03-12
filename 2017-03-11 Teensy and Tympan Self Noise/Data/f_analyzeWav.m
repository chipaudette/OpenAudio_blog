function [rms_wav,ave_spec,freq_Hz,proc_wavs]=f_analyzeWav(wav,fs_Hz, bp_Hz, t_lim_sec,cal_V_per_count, Nfft);

wav_mr = wav - ones(size(wav,1),1)*mean(wav);

%bandpass filter
%bp_Hz = [125 8000];
if isnumeric(bp_Hz)
    N_fir = fs_Hz/bp_Hz(1) * 3;
    N_fir = 2*round(0.5*N_fir);
    [b,a]=weaFIR(N_fir,bp_Hz/(fs_Hz/2));
    fwav = filter(b,a,wav_mr);
    fwav = fwav(N_fir/2+1:end,:);  %remove filter latency
elseif isstr(bp_Hz)
    if bp_Hz(1) == 'A'
        %A-weighting
        [b,a]=define_a_weighting_timeDomain(fs_Hz);
        fwav = filter(b,a,wav_mr);
    end
end

%trim
if ~isempty(t_lim_sec)
    inds = round(fs_Hz*t_lim_sec);
else
    inds = [round(fs_Hz*0.1) size(wav,1)-round(fs_Hz*0.1)];
end
wav = wav(inds(1):inds(2),:);
wav_mr = wav_mr(inds(1):inds(2),:);
fwav = fwav(inds(1):inds(2),:);
t_sec = ([1:size(wav,1)]-1)/fs_Hz;

%calibrate
%cal_V_per_count = 0.7571 / sqrt(10.^(0.1*in_gain_dB));  %from pre-AAS testing
wav_mr_V = wav_mr * cal_V_per_count;
fwav_V = fwav * cal_V_per_count;

%assess level
wav_mr_FSrms = sqrt(mean(wav_mr.^2));
fwav_FSrms = sqrt(mean(fwav.^2));
fwav_Vrms = sqrt(mean(fwav_V.^2));


%get average spectrum
spec_V_sqrtHz = []; spec_counts_sqrtHz=[];
%Nfft = 2*round(0.125*fs_Hz);
plots=0;overlap=0.75;window='hanning';
[pD_perBin,f]=windowedFFTPlot(wav_mr- mean(wav_mr),Nfft,overlap,fs_Hz,plots,window);
Hz_perBin = fs_Hz / Nfft;
pD_perHz = pD_perBin / Hz_perBin;
spec_counts_sqrtHz = sqrt(pD_perHz(:));
spec_V_sqrtHz = spec_counts_sqrtHz * cal_V_per_count;



% pack up the data
rms_wav=[];
rms_wav.mr_FSrms = wav_mr_FSrms;
rms_wav.fwav = fwav_FSrms;
rms_wav.fwav_Vrms = fwav_Vrms;
ave_spec=[];
ave_spec.V_sqrtHz = spec_V_sqrtHz;
ave_spec.counts_sqrtHz = spec_counts_sqrtHz;
freq_Hz = f;
proc_wavs=[];
proc_wavs.wav = wav;
proc_wavs.wav_mr = wav_mr;
proc_wavs.fwav = fwav;
proc_wavs.wav_mr_V = wav_mr_V;
proc_wavs.fwav_V = fwav_V;


