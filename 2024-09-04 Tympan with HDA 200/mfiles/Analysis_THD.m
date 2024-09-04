
fname_pre = '4000_0_'
I=find(fname_pre == '_')
if isempty(I)
    I = length(fname_pre)
end
freq = str2num(fname_pre(1:I(1)-1));

channel = 1; %set 1 for acoustic or 2 for electrical measurement

% electrically measured the signal going to the headset by splitting the
% output, one to the headset and one to a channel in the DAQ (see picture
% in email (AMV 5/2/2024)

%for freq = [5000]
% for freq = [125 250 500 1000 2000]
fname = [fname_pre 'A.wav'];			%form the file name
[wav, fs_Hz] = loadWavAndDat(fname);	%load the audio data and sample rate
wav = wav(:,channel); 					%channel 1 is acoustic 2 is electric

if ((channel == 2) & (freq > 5001))  
    % for all cases above 5k Hz and measured electrically
    upper_limit_Hz = min([0.95*fs_Hz/2, 50000]); % Chip says some # that smart big not stupid big. I don't think he knows what he is talking about
else 
    % for all cases measured acoustically
    upper_limit_Hz = 20000;
end;

% process the audio
flag_useWindow = 1;  %0 = no windowing, 1 = hanning window
[fft_table_rms, fft_freq_Hz] = rmsFFT_THD(wav, fs_Hz, flag_useWindow);

% blindly loop over all harmonics
all_measured_Hz = [];		all_measured_rms = []; %initialize so that they can be used later
for Iharmonic = 1:100

    %is this the first time through?  Are we identifying the fundamental?
    if (Iharmonic == 1)
        % find the fundamental frequency
        if (1)
            % assume that we're given the correct target frequency
            fund_freq_Hz = freq;  %use the given frequency
            disp(['Assuming the fundamental is ' num2str(fund_freq_Hz) ' Hz']);
        else
            %assume the fundamental is the strongest peak in the fft
            [foo,Imax]=max(fft_table_rms);          %find the strongest bin in the FFT
            fund_freq_Hz = fft_freq_Hz(Imax);  %get the frequency value for the strongest bin

            %do we want to get a more refined frequency value for the fundamental??
            if (1)   %set 1=yes, 0=no
                fund_freq_Hz = getFreqFromZeroCrossings(wav,fs_Hz,50.0,fund_freq_Hz);
                disp(['High-resolution estimate of fundamental = ' num2str(fund_freq_Hz) ' Hz']);
            end
        end
    end

    %what frequency are we looking for?
    target_freq_Hz = Iharmonic * fund_freq_Hz;

    %only process if target frequency is less than 20000
    if (target_freq_Hz <= upper_limit_Hz)

        %measure the RMS amplitude at this frequency
%             search_width_bins = Iharmonic*2.0;  %We're going to search over a small window to find the peak.  Make sure that this setting grows a bit wider with every harmonic.
        search_width_Hz = .05 * target_freq_Hz;
        hz_per_bin = median(diff(fft_freq_Hz));
        search_width_bins = search_width_Hz/hz_per_bin;
        search_width_bins = max([search_width_bins, 3]);

        measurement_width_bins = 3;         %When measuring the RMS, how many fft bins to include. (keep as an odd number...1,3,5,7)
        [measured_rms, measured_Hz] = measureRmsAtFreq(fft_freq_Hz, fft_table_rms, target_freq_Hz, search_width_bins, measurement_width_bins);

        %save the results
        all_measured_Hz(end+1) = measured_Hz;
        all_measured_rms(end+1) = measured_rms;

    end

end  %end loop over harmonic


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Additional analysis of the measured distortion values

% compute THD from the raw RMS measurements
total_THD_perc = 0.0; max_harm_THD_perc = 0.0;  %initialize
fund_rms = all_measured_rms(1);  %the funamental is first
all_THD_perc = 100* all_measured_rms / fund_rms;
if (length(all_measured_rms) > 1)
    total_THD_perc = 100* sqrt(sum(all_measured_rms(2:end).^2)) / fund_rms;
    max_harm_THD_perc = max(all_THD_perc(2:end));
end

% print out some metrics from this analysis
disp(['Report for freq=' num2str(freq) ': ' ...
    'fund = ' num2str(round(fund_freq_Hz)) ' Hz, ' ...
    'SPL = ' num2str(20*log10(all_measured_rms(1)/20e-6)) ' dB (unweighted), ' ...
    num2str(length(all_measured_Hz)) ' harmonics analyzed.  ' ...
    'THD = ' num2str(total_THD_perc) '%, ' ...
    'worst harmonic = ' num2str(max_harm_THD_perc) '%']);

% specifically note failing harmonics
bad_thresh_perc = 0.3;
if (max_harm_THD_perc >= bad_thresh_perc)
    disp(['WARNING: at least one harmonic is greater than ' num2str(bad_thresh_perc) '%'])
    for I = [2:length(all_THD_perc)]
        if (all_THD_perc(I) >= bad_thresh_perc)
            disp(['    : Harmonic ' num2str(I) ', Distortion = ' num2str(all_THD_perc(I)) '%']);
        end
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot the results!

%prepare some numbers for plotting
fft_table_dBSPL = 20*log10( (fft_table_rms/20e-6) );        %convert to dB SPL
all_measured_dBSPL = 20*log10( (all_measured_rms/20e-6) );  %convert to dB SPL
fund_dBSPL = all_measured_dBSPL(1);                %what is the SPl of the fundamental
fund_Pa = 20e-6*(10.^(all_measured_dBSPL(1)/20));  %convert to pascals
bad_thresh_Pa =  bad_thresh_perc/100*fund_Pa;      %what is the "bad" threshold expressed in pascals
bad_thresh_dBSPL = 20*log10(bad_thresh_Pa/20e-6);  %what is the "bad" threshold expressed as dB SPL

%do the plotting
figure;
setFigureParameters;
semilogx(fft_freq_Hz, fft_table_dBSPL, 'r');  %plot the fft spectrum
hold on
plot(all_measured_Hz, all_measured_dBSPL,'ko');  %plot all the harmonics that we measured
xlim([20, upper_limit_Hz])
plot(xlim,bad_thresh_dBSPL*[1 1],'k--');  %plot a line showing the worst allowed distortion
xl=xlim;yl=ylim;
text(xl(1)*1.1,bad_thresh_dBSPL,[num2str(bad_thresh_perc) '%'],...
    'horizontalalignment','left','verticalalignment','middle','backgroundcolor','white');
hold off

title(['Case: ' num2str(freq) ' (Actual = ' num2str(round(fund_freq_Hz)) ', THD = ' num2str(total_THD_perc) '%)'])
xlabel('Frequency(Hz)')
ylabel('dB SPL')
xlim([20, upper_limit_Hz])
ylim([-30, 120])

%     create rough limit plot
%     hold on
%     xfloor= [125 250 500 750 1000 1500 2000 3000 4000 5000 6000 8000 9000 10000 11200 12500 14000 16000];
%     yfloor= [20.5 8 1 -4 -4.5 -4.5 -5.5 -7.5 -0.5 4 7 7.5 9 12 13 17.5 25 46];
%     semilogx(xfloor,yfloor,'--k')
%     legend('Noise Floor', 'Target Noise Floor')
%     hold off

savefig([fname_pre '.fig'])
saveas(gcf, fname_pre, 'pdf')



