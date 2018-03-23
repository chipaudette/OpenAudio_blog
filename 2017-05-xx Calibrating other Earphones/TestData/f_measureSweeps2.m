function [out]=f_measureSweeps2(wav,fs_Hz,t_start_sec,params)

out=[];

%get RMS in fixed intervals
window_sec = 0.1; step_sec = 0.0125;
t_win_sec = [window_sec/2:step_sec:(size(wav,1)/fs_Hz-window_sec/2)];
wav_win_rms = NaN*ones(length(t_win_sec),size(wav,2));
disp(['stepping through windows of time...']);drawnow
for Iwin = 1:length(t_win_sec);
    win_sec = t_win_sec(Iwin)+window_sec*[-0.5 0.5];
    inds = round(fs_Hz*win_sec);
    inds(1) = max([1 inds(1)]); inds(2) = min([size(wav,1) inds(2)]);
    foo_wav  = wav(inds(1):inds(2),:);
    foo_wav = foo_wav - ones(size(foo_wav,1),1)*mean(foo_wav);  %mean removed
    wav_win_rms(Iwin) = sqrt(mean(foo_wav.^2));
end

%distribute values to every sample
wav_rms = NaN*ones(size(wav));
if (0)
    disp(['distributing over every sample...']);drawnow;
    for Ichan=1:size(wav_rms)
        wav_rms(:,Ichan) = interp1(t_win_sec,wav_win_rms,([1:size(wav,1)]-1)/fs_Hz);
    end
else
end
out.wav_rms = wav_rms;

%define timing of start of each sweep
t_sweep_sec = t_start_sec+(params.t_sweep_sec+params.t_silence_sec)*([1:params.n_cycles]-1)+params.t_silence_sec;
out.t_sweep_sec = [t_sweep_sec(:) t_sweep_sec(:)+params.t_sweep_sec];

%find frequency for each time window
df_per_sec = (params.f_end_Hz - params.f_start_Hz)/params.t_sweep_sec;
f_win_Hz = NaN*ones(size(wav_win_rms,1),1);
win_sweep_id = NaN*ones(size(wav_win_rms,1),1);
for Iwin=1:size(f_win_Hz)
    I=find(t_sweep_sec < t_win_sec(Iwin));
    if ~isempty(I)
        if (t_win_sec(Iwin) < (t_sweep_sec(I(end))+params.t_sweep_sec))
            dt_sec = t_win_sec(Iwin) - t_sweep_sec(I(end));
            f_win_Hz(Iwin) = params.f_start_Hz + df_per_sec*dt_sec;
            win_sweep_id(Iwin) = I(end);
        end
    end
end
out.t_win_sec = t_win_sec;
out.f_win_Hz = f_win_Hz;
out.wav_win_rms = wav_win_rms;
out.win_sweep_id = win_sweep_id;

n_sweep = params.n_cycles;
    

%get intensity at discrete frequencies
%targ_freq_Hz = [125 250 500 1000 2000 4000 8000];
targ_freq_Hz = 125*2.^([0:1/3:7]);
targ_rms = NaN*ones(length(targ_freq_Hz),size(wav_win_rms,2));
%for Ichan=1:size(wav_win_rms,2)
    for Itarg=1:length(targ_freq_Hz);
        for Isweep = 1:n_sweep;
            I = find(win_sweep_id == Isweep);
            if (0)
                win_frac = (1/6)/2;
                f_Hz = targ_freq_Hz(Itarg)*[1-win_frac 1+win_frac];
                J=find((f_win_Hz(I) >= f_Hz(1)) & ...
                    (f_win_Hz(I) <= f_Hz(2)) );
                if ~isempty(J)
                    %targ_rms(Itarg,Ichan) = sqrt(mean(wav_win_rms(I(J)).^2));
                    targ_rms(Itarg,Isweep) = sqrt(mean(wav_win_rms(I(J)).^2));
                end
            else
                [foo,J]=min(abs(targ_freq_Hz(Itarg) - f_win_Hz(I)));
                targ_rms(Itarg,Isweep) = wav_win_rms(I(J));
            end
        end
    end
%end
out.targ_freq_Hz = targ_freq_Hz;
out.targ_rms = targ_rms;

