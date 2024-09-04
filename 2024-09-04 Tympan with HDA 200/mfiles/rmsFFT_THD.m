function varargout = rmsFFT(x, fs_Hz, flag_useWindow)
% Returns the FFT of vector x in RMS units
%
% [A_rms, f_Hz] = rmsFFT(x, fs_Hz, flag_useWindow);
% A_rms = rmsFFT(x,fs_Hz);
%
% inputs:
% x = time domain signal in engineering units (e.g, Pa)
% fs_Hz = sample rate, Hz
% flag_useWindow = (default 0) set to 1 to apply a Hanning window prior to the FFT
%
% outputs:
% A_rms = RMS FFT result, in RMS engineering units (e.g. Pa_{RMS})
% f_Hz = freqeuncy vector, Hz (optional)

if (nargin < 3)
	flat_useWindow = 0;  %default to NOT window the data (to be consistent with historical versions of this program)
end

%ensure that we only do an even-length FFT
N = floor(length(x)/2)*2; %ensure even length
x = x(1:N);  %trim off any excess samples to force to even length

%apply window
if (flag_useWindow)
	win = hanning(N);  %use a hanning window
	x = win.*x;          %apply the hanning window
	amplitude_correction = 1.0/(sqrt(mean(win.^2))); %as the windowing attenuates part of the signal, we should correct the amplitude by boosting it back up
	x = amplitude_correction*x;
end

%compute the ffft
foo = fft(x); %take the fft
foo = abs(foo);  %convert from complex to real
foo = foo / N;   %convert to average through time

%keep only the positive frequency space
foo = foo(1:(N/2+1));  %keep only positive
Aout = sqrt(2)*foo;     %correc tthe amplitude because we threw away half the energy, and energy goes as P^2, hence sqrt(2) as (sqrt(2)^2 = 2)


%prepare the output
freq_Hz = fs_Hz*(0:N/2)./N; %FFT Frequency Vector (should be same length as Aout
varargout{1} = Aout;
varargout{2} = freq_Hz;

