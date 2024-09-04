function new_freq_Hz = getFreqFromZeroCrossings(wav,fs_Hz,hp_Hz,approx_freq_Hz);
%function new_freq_Hz = getFreqFromZeroCrossings(wav,fs_Hz,hp_Hz,approx_freq_Hz);
%
% Measure the frequency based on the waveform crossing zero.
% This only works if the frequency that you care about is (by far) the strongest signal present.
%
% wav: you signal of interest (mono only)
% fs_Hz: sample rate of the WAV file
% hp_Hz: cutoff frequency for the highpass filter used to pre-process the data
% approx_freq_Hz: a guess at the approximate frequency that you are looking for. [only searches for a frequency within 10% of this value]

if (nargin < 4)
	approx_freq_Hz = [];
	if (nargin < 3);
		hp_Hz = 50.0;
	end
end

% pre-process the WAV file
foo_wav = wav - mean(wav);  %remove any DC offset in the wav data
[b,a]=butter(2,hp_Hz/(fs_Hz/2));  %make a highpass filter (in addition to the DC offset removal)
foo_wav = filter(b,a,foo_wav); %apply the highpass filter

% find the zero crossings
I_crossings = find((foo_wav(1:end-1) < 0) & (foo_wav(2:end) >= 0));  %find every up-going crossing of zero

% calc the time difference between successive crossings
dt_crossings_sec = diff(I_crossings)/fs_Hz;  %this could include lots of low-quality values due to noise or corruption

% to reduce the effect of noise and corruption keep only the zero crossings that are similar to the expected value
if isempty(approx_freq_Hz)
  %get an approximate value from the data itself
	dt_expected_sec = median(dt_crossings_sec);  %hopefully this is approximately right
else
	%use the given value
	dt_expected_sec = 1./approx_freq_Hz;  %here's the time difference that we expect based on the FFT results (the FFT is good at ignoring noise and corruption)
end
Ikeep = find((dt_crossings_sec >= 0.9*dt_expected_sec) & (dt_crossings_sec < 1.1*dt_expected_sec)); %keep only those measured values that are close to the expected value

%estimate the signal frequency from the mean of these "good" zero crossings
mean_dt_sec = mean(dt_crossings_sec(Ikeep));%take the average of the good measured values, which (given how many zero-crossings we're averaging together) should give a super-refined estimate of the true signal frequency
new_freq_Hz = 1./mean_dt_sec; 
