function [measured_rms,measured_freq_Hz] = measureRmsAtFreq(fft_freq_Hz, fft_rms_table, target_freq_Hz, search_width_bins, measurement_width_bins);
%function measured_rms = measureRmsAtFreq(fft_freq_Hz, fft_rms_table, target_freq_Hz, search_width_bins, measurement_width_bins)
%
% Measure the RMS of the signal at the target frequency.
%
% This routine searches for a peak in the fft requests around the target frequency (search_width_bins) and
% then sums the FFT power for bins centered on that detected peak (measurement width_bins).
%
% fft_freq_Hz: frequencies from the FFT analysis
% fft_rms_table: rms values from the FFT analysis
% target_freq_Hz: the frequency that you are targeting for getting the RMS values
% search_width_bins: how many bins to search, around the target frequency...will be forced to be odd
% measurement_width_bins: how many bins around the peak to include in the measurement of the peak...will be forced to be odd
%

if (nargin < 5)
	measurement_width_bins = 3;
	if (nargin < 4)
		search_width_bins = 5;
	end
end


%find the bin closest to the target frequency
[foo,I] = min(abs(fft_freq_Hz  - target_freq_Hz));

%search near-by bins and find the peak
if (search_width_bins <= 1)
	search_width_bins = 1;
else
	search_width_bins = 2*round((search_width_bins-1)/2)+1;  %force to be odd
end
width_bins_half = round((search_width_bins-1)/2);
inds = I + [-width_bins_half:width_bins_half];  %here are the indices that we'll search
[foo,J] = max(fft_rms_table(inds));  %find the peak
Ipeak = inds(J);  %here is the index of the peak
measured_freq_Hz = fft_freq_Hz(Ipeak);

%sum the bins around the peak
if (measurement_width_bins <= 1)
	measurement_width_bins = 1;
else
	measurement_width_bins = 2*round((measurement_width_bins-1)/2)+1;  %force to be odd
end
width_bins_half = round((measurement_width_bins-1)/2);
inds = Ipeak + [-width_bins_half:width_bins_half];  %here are the indices that we'll search
measured_rms = sqrt(sum(fft_rms_table(inds).^2));
	
	