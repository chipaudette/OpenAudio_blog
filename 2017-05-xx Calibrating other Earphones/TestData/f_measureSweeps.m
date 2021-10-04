function [out]=f_measureSweeps(wav,fs_Hz,t_start_sec,params)

out=[];


%use hilbert to compute frequency and amplitude
hwav = hilbert(wav);
wav_rms = abs(hwav)/sqrt(2);
wav_rad = unwrap(angle(hwav));
if (0)
    %cutoff_rad_sec = 16000*2*pi / fs_Hz;
    [b,a]=butter(2,0.01);
    wav_rad = filtfilt(b,a,wav_rad);
end
freq_Hz = diff(wav_rad)/(2*pi) * fs_Hz;
if (1)
    if isempty(params)
        t_foo = 10;
    else
        t_foo = params.t_sweep_sec;
    end
    cutoff_Hz = 0.1*(16000-100)/t_foo;
    [b,a]=butter(1,cutoff_Hz/(fs_Hz/2));
    freq_Hz = filtfilt(b,a,freq_Hz);
end

out.wav_rms = wav_rms;

if isempty(params)
    return;
end

%assume start of each sweep
t_sweep_sec = t_start_sec+(params.t_sweep_sec+params.t_silence_sec)*([1:params.n_cycles]-1)+params.t_silence_sec;
out.t_sweep_sec = [t_sweep_sec(:) t_sweep_sec(:)+params.t_sweep_sec];


%seperate data into each individual sweep
out.freq_Hz = [];
out.rms=[];
dur_samp = round(params.t_sweep_sec * fs_Hz);
for Isweep=1:length(t_sweep_sec);
    inds = round(t_sweep_sec(Isweep)* fs_Hz) + ([1:dur_samp]-1);
    inds = inds(find(inds < length(freq_Hz)));
    out.freq_Hz(:,Isweep) = freq_Hz(inds);
    out.rms(:,Isweep) = wav_rms(inds);
end

%get intensity at discrete frequencies
%targ_freq_Hz = [125 250 500 1000 2000 4000 8000];
targ_freq_Hz = 125*2.^([0:1/3:7]);
targ_rms = NaN*ones(length(targ_freq_Hz),size(out.rms,2));
for Ichan=1:size(out.rms,2)
    for Itarg=1:length(targ_freq_Hz);
        win_frac = (1/6)/2;
        f_win_Hz = targ_freq_Hz(Itarg)*[1-win_frac 1+win_frac];
        I=find((out.freq_Hz(:,Ichan) >= f_win_Hz(1)) & ...
            (out.freq_Hz(:,Ichan) <= f_win_Hz(2)) );
        if ~isempty(I)
            targ_rms(Itarg,Ichan) = sqrt(mean(out.rms(I,Ichan).^2));
        end
    end
end
out.targ_freq_Hz = targ_freq_Hz;
out.targ_rms = targ_rms;

