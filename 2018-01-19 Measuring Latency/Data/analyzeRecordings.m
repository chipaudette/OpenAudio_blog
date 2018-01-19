
% analyzeRecordings.m
%
% Created: April 2017, openaudio.blogspot.com
% Purpose: Analyze stereo audio recording to find the delay (latency) of 
%     the audio in the right channel relative to the audio in the left
%     channel.  This is to assess the latency of audio passing through
%     the Tympan.
% License: Open Source.  2017.  MIT License (https://opensource.org/licenses/MIT)


% For the Typman, the expected minimum latency of a round-trip through the 
%    system is ultimately limited by the internal workings of the TI 3206 
%    AIC that is at the heart of the Tympan.  From its documentation:
%
%       * AIC ADC oversampling filter (A) has 17 sample group delay
%       * AIC DAC reconstruction filter (A) has 21 sample group delay
%
%    So, I would expect the minimum latency to be 17+21 = 38 samples.  At
%       a sample rate of 24 kHz, this would be 1.58 milliseconds.
%
% Additionally, the audio library used by the Teensy (which is the processor
%    at the heart fo the Tympan) seems to always have two audio blocks
%    in the queue.  I believe that this would add to the minimum latency.
%    
%    With the Tympan library, you have control over the data block size.
%    For a block size of 16 samples, the total system latency should be
%    38 samples + 2*16 samples, which is a total of 70 samples.  At a 
%    sample rate of 24 kHz, this is 2.92 msec.
%
% Let's analyze some data to find out what the latency actually is!

%define data file to process
pname = 'RawData\'; %path name
fname = 'R05_0031.wav'; %file name

%extra info for annotating the plots
name = 'Pass-Thru, fs=24kHz';  %description of the algorithm runnin on the tympan
block_size = 16;  %what is the audio block size used inside the tympan
tympan_fs_Hz = 24000; %what is the sample rate inside typman itself

%load audio recording
disp(['loading ' pname fname]);
[wav,fs_Hz]=audioread([pname fname]);


%% analyze the data

%do cross correlation to measure the latency of the right channel vs the left channel
[r,lags]=xcorr(wav(:,2),wav(:,1));
[foo,Ibest]=max(abs(r));
best_lag = lags(Ibest);

disp(['The latency appears to be ' num2str(best_lag/fs_Hz*1000) ' msec']);


%% plots

%first filter the data to make them visually more clear
[b,a] = butter(2,[700 1500]/(fs_Hz/2)); %bandpass filter around expected audio frequency (1kHz)
foo_wav = filter(b,a,wav);
foo_wav(:,1)=-foo_wav(:,1)*1*sqrt(2);

for Iplot=1:2 %first is zoomed out, second is zoomed in
    figure;
    t_sec = ([1:size(foo_wav,1)]-1)/fs_Hz;
    
    subplot(2,1,1);
    I=find(abs(foo_wav(:,1))> 0.0002);
    t_offset = (I(1)-1)/fs_Hz;
    plot((t_sec-t_offset)*1000,foo_wav(:,1));
    title('Direct Audio Signal');
    if Iplot==2;hold on;plot([0 0],ylim,'k--','linewidth',2);hold off;end
    ax=gca;
    
    subplot(2,1,2);
    plot((t_sec-t_offset)*1000,foo_wav(:,2));
    xlabel('Time (msec)');
    t_lag_sec = best_lag/fs_Hz;
    if Iplot==2
        hold on;plot(t_lag_sec*1000*[1 1],ylim,'k--','linewidth',2);hold off;
        hold on; plot([0 0],ylim,'k:');hold off;
    end
    ax(end+1) =gca;
    
    linkaxes(ax,'x');
    if Iplot==1
        xlim([-250 5250]);
    else
        %zoom in
        xlim([-2 10]);
        yl=ylim;
        text(t_lag_sec*1000,yl(1)+0.05*diff(yl), ...
            {num2str(t_lag_sec*1000,2);'msec'}, ...
            'HorizontalAlignment','center','VerticalAlignment','bottom',...
            'BackgroundColor','white');
    end
    title(['Signal From Tympan: ' name ', block size = ' num2str(block_size)]);
end
