
fs_Hz = 44100;
freq_Hz = 2000;
amp_FS_dB = 0;  %what is the amplitude of fullscale?
outpname = 'InputSignals\';

%make swept amplitude
for Iwav=1:2
    if Iwav==1
        dur_sec = 10;
        outfname = [outpname 'input_ampSweep_'];
    else
        dur_sec = 50;
        outfname = [outpname 'inputLong_ampSweep_'];
    end
    amp_dB = [-50 0]-6;
    t_sec = ([1:dur_sec*fs_Hz]-1)/fs_Hz;
    wav = sin(2*pi*freq_Hz*t_sec);
    wav = wav./sqrt(mean(wav.^2)) * sqrt(10.^(0.1*amp_FS_dB));
    gain_dB = interp1(t_sec([1 end]),amp_dB,t_sec);
    gain = sqrt(10.^(0.1*gain_dB));
    wav = wav.*gain;
    outfname = [outfname num2str(amp_dB(1)) '_' num2str(amp_dB(2)) 'dB.wav'];
    disp(['writing ' outfname]);
    audiowrite(outfname,wav,fs_Hz,'BitsPerSample',16);
end

%make stepped amplitude
for Iwav = 1:2
    if Iwav==1
        step_dur_sec = 1;
        outfname = [outpname 'input_ampSteps_'];
    else
        step_dur_sec = 10;
        outfname = [outpname 'inputLong_ampSteps_'];
    end
    amp_dB = [0 -25 0 -25 0]-6;
    dur_sec = length(amp_dB)*step_dur_sec;
    t_sec = ([1:dur_sec*fs_Hz]-1)/fs_Hz;
    wav = sin(2*pi*freq_Hz*t_sec);
    wav = wav./sqrt(mean(wav.^2)) * sqrt(10.^(0.1*amp_FS_dB));
    gain_dB = zeros(size(wav));
    for I=1:length(amp_dB)
        inds = find((t_sec >= (I-1)*step_dur_sec) & (t_sec <= I*step_dur_sec));
        gain_dB(inds) = amp_dB(I);
    end
    gain = sqrt(10.^(0.1*gain_dB));
    wav = wav.*gain;
    outfname = [outfname num2str(amp_dB(1)) '_' num2str(amp_dB(2)) 'dB.wav'];
    disp(['writing ' outfname]);
    audiowrite(outfname,wav,fs_Hz,'BitsPerSample',16);
end

