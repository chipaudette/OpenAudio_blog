

if (1)
    pname = 'RawData\';
    fname = '02-ShortedInputs_SteppedGain_0_10_20_30_40dB.wav'; t_start_sec = 14.4;in_gain_dB = [0 10 20 30];
    sname = 'Tympan, Shorted Inputs, Saved via USB Audio';
    gain_dur_sec = 3.05;
else
    pname = 'RawData\TeensySD\';
    %fname = '01-ShortedInputs_InputGain_0_10_20_30_40dB_USBconnected.RAW';sname = 'Tympan, Shorted Inputs, Saved to SD, USB Power';
    fname = '02-ShortedInputs_InputGain_0_10_20_30_40dB_USBdisconnected.RAW';sname = 'Tympan, Shorted Inputs, Saved to SD, No USB';
    t_start_sec = [];in_gain_dB = [0 10 20 30];
    gain_dur_sec = 3.00;
end


t_name={};t_process_sec=[];

for Igain=1:length(in_gain_dB)
    t_process_sec(end+1,:) = [(Igain-1)*gain_dur_sec + [0.2 gain_dur_sec-0.2]];
    t_name{end+1} = ['Gain ' num2str(in_gain_dB(Igain)) ' dB'];
end


%% load data
disp(['loading ' pname fname]);
if strcmpi(fname(end-2:end),'wav');
    [wav,fs_Hz]=audioread([pname fname]);
else
    fid = fopen([pname fname]);
    if fid == -1
        disp(['*** ERROR ***: couldn not open ' pname fname]);
        return;
    end
    wav = fread(fid,'int16');
    wav = wav / 2^15;
    fclose(fid);
    fs_Hz = 44100;  %assumed
end
%keep only the left channel
% foo = wav - ones(size(wav,1),1)*mean(wav);
% rms_foo = sqrt(mean(foo.^2));
% [foo_rms,I]=max(rms_foo);
wav = wav(:,1);

%trim to start
if ~isempty(t_start_sec)
    ind = round(fs_Hz * t_start_sec);
    wav = wav(ind:end,:);
end

%trim to 3*5 seconds
t_trim_sec = gain_dur_sec*length(in_gain_dB);
if size(wav,1) > fs_Hz*t_trim_sec
    wav = wav(1:round(fs_Hz*t_trim_sec),:);
end

t_sec = ([1:size(wav,1)]'-1)/fs_Hz;

% remove mean
wav_mr = wav - ones(size(wav,1),1)*mean(wav);

%% process data
rms_level_dBV = [];
for Iprocess=1:size(t_process_sec,1)
    inds = round(fs_Hz*t_process_sec(Iprocess,:));
    rms_level_dBV(Iprocess,:) = 10*log10(mean(wav_mr(inds(1):inds(2),:).^2));
end

%compute calibration coefficient
cal_V_per_count = 0.7571;  %from pre-AAS testing
%wav_mr_V = wav_mr*cal_V_per_count;

%get average spectrum for each time period
spec_V_sqrtHz = []; spec_counts_sqrtHz=[];
Nfft = 2*round(0.125*fs_Hz);
Vrms_flim=[];FSrms_flim=[];
for Iprocess=1:size(t_process_sec,1);
    inds = round(fs_Hz*t_process_sec(Iprocess,:));
    plots=0;overlap=0.75;window='hanning';
    
    [pD_perBin,f]=windowedFFTPlot(wav_mr(inds(1):inds(2)),Nfft,overlap,fs_Hz,plots,window);
    Hz_perBin = fs_Hz / Nfft;
    pD_perHz = pD_perBin / Hz_perBin;
    spec_counts_sqrtHz(:,Iprocess) = sqrt(pD_perHz(:));
    
    spec_V_sqrtHz(:,Iprocess) = spec_counts_sqrtHz(:,Iprocess) * cal_V_per_count / sqrt(10.^(0.1*in_gain_dB(Iprocess)));
    %     [pD_perBin,f]=windowedFFTPlot(wav_mr_V(inds(1):inds(2)),Nfft,overlap,fs_Hz,plots,window);
    %     Hz_perBin = fs_Hz / Nfft;
    %     pD_perHz = pD_perBin * Hz_perBin;
    %     spec_V_sqrtHz(:,Iprocess) = sqrt(pD_perHz(:));
    
    %assess over 1-8 kHz
    f_lim_Hz = [250 8000];
    I = find((f >= f_lim_Hz(1)) & (f <= f_lim_Hz(2)));
    FSrms_flim(Iprocess) = sqrt(mean(spec_counts_sqrtHz(I,Iprocess).^2)*(diff(f_lim_Hz)));
    Vrms_flim(Iprocess) = sqrt(mean(spec_V_sqrtHz(I,Iprocess).^2)*(diff(f_lim_Hz)));
end
freq_Hz = f;

%% plots
figure;setFigureTallWide;ax=[];
nrow=2;ncol=2;
subplot(nrow,ncol,1);
dec_fac = 10;
plot(t_sec(1:dec_fac:end),wav(1:dec_fac:end,:));
xlabel('Time (sec)');
ylabel({'Recorded Value';'(from USB or SD)'});
title(sname,'interpreter','none');
ylim([-1 1]);
xlim(t_sec([1 end]));
ax(end+1) = gca;

for I = 1:size(t_process_sec,1)
    yl=ylim;
    hold on;
    plot(t_process_sec(I,1)*[1 1],yl,'g:','linewidth',2);
    plot(t_process_sec(I,2)*[1 1],yl,'r:','linewidth',2);
    hold off
end

subplot(nrow,ncol,2);
N = 1024; overlap=0.5;
[pD,wT,f]=windowedFFTPlot_spectragram(wav_mr,N,overlap,fs_Hz);
set(gca,'Clim',10*log10(1/1024)+[-100 0]);
xlim(t_sec([1 end]));
ax(end+1) = gca;

subplot(nrow,ncol,3);
semilogx(freq_Hz, 20*log10(spec_counts_sqrtHz));
legend(t_name);
xlabel('Frequency (Hz)');
ylabel('dB re: FS/sqrt(Hz)');
xlim([10 20000]);
ylim([-140 0]);
title(sname,'interpreter','none');
weaText({['fs = ' num2str(fs_Hz/1000) ' kHz'];
    ['Nfft = ' num2str(Nfft)]},2);


subplot(nrow,ncol,4);
semilogx(freq_Hz, 20*log10(spec_V_sqrtHz));
legend(t_name);
xlabel('Frequency (Hz)');
ylabel('dB re: 1 V/sqrt(Hz)');
xlim([10 20000]);
ylim([-160 -80]);
title(sname,'interpreter','none');
weaText({['fs = ' num2str(fs_Hz/1000) ' kHz'];
    ['Nfft = ' num2str(Nfft)]},2);

linkaxes(ax,'x');

%% summary
%figure;pos=get(gcf,'position');
%new_h = 1.5*pos(4); set(gcf,'position',[pos(1) pos(2)-(new_h-pos(4)) pos(3) new_h]);
figure
setFigureTallerWide;
set(gcf,'position',[245          67        1120         745]);
c=lines;

subplot(3,2,1);
max_dBFS = -3;
plot(in_gain_dB, max_dBFS*ones(size(in_gain_dB)),'o-','linewidth',2,'color',c(1,:));
xlabel('Input Gain (dB)');
ylabel('Max Input (dB FS)');
title(sname,'interpreter','none');
ylim([-40 0]);

subplot(3,2,2);
y_dB = 20*log10(FSrms_flim);
plot(in_gain_dB, y_dB,'o-','linewidth',2,'color',c(2,:));
xlabel('Input Gain (dB)');
ylabel({'Self-Noise';['(dB FS, ' num2str(f_lim_Hz(1)/1000) '-' num2str(f_lim_Hz(2)/1000) ' kHz)']});
title(sname,'interpreter','none');
ylim(-100+40*[-0.2 0.8])
% hold on;
% plot(in_gain_dB([1 end]), y_dB(1)+[0 -diff(in_gain_dB([1 end]))],'k--','linewidth',2);
% hold off;
hold on;
y=min(y_dB);
plot(in_gain_dB([1 end]),y*[1 1],'k--','linewidth',2);
hold off;
text(in_gain_dB(end)-0.05*diff(xlim),y, ...
    [num2str(y,3) ' dBV'],'backgroundcolor','white',...
    'verticalalignment','middle','horizontalalignment','right');



subplot(3,2,3);
max_dBV_zero_gain = max_dBFS+20*log10(cal_V_per_count);
y2_dB = max_dBV_zero_gain-in_gain_dB;
plot(in_gain_dB, y2_dB,'o-','linewidth',2,'color',c(1,:));
xlabel('Input Gain (dB)');
ylabel('Max Input (dBVrms)');
title(sname,'interpreter','none');
ylim([-40 0]);
hold on;
y=max(y2_dB);
plot(in_gain_dB([1 end]),y*[1 1],'k--','linewidth',2);
hold off;
text(in_gain_dB(end)-0.05*diff(xlim),y, ...
    [num2str(y,3) ' dBV'],'backgroundcolor','white',...
    'verticalalignment','middle','horizontalalignment','right');

subplot(3,2,4);
y_dB = 20*log10(Vrms_flim);
plot(in_gain_dB, y_dB,'o-','linewidth',2,'color',c(2,:));
xlabel('Input Gain (dB)');
ylabel({'Self-Noise';['(dBVrms, ' num2str(f_lim_Hz(1)/1000) '-' num2str(f_lim_Hz(2)/1000) ' kHz)']});
title(sname,'interpreter','none');
ylim(-115+40*[-0.2 0.8])
% hold on;
% plot(in_gain_dB([1 end]), y_dB(1)+[0 -diff(in_gain_dB([1 end]))],'k--','linewidth',2);
% hold off;
hold on;
y=min(y_dB);
plot(in_gain_dB([1 end]),y*[1 1],'k--','linewidth',2);
hold off;
text(in_gain_dB(1)+0.05*diff(xlim),y, ...
    [num2str(y,3) ' dBV'],'backgroundcolor','white',...
    'verticalalignment','middle','horizontalalignment','left');


subplot(3,2,5)
plot(in_gain_dB, [y2_dB(:) y_dB(:)],'o-','linewidth',2);
xlabel('Input Gain (dB)');
ylabel({'Input Signal Amplitude';...
    ['(dBVrms, ' num2str(f_lim_Hz(1)/1000) '-' num2str(f_lim_Hz(2)/1000) ' kHz)']});
ylim([-140 20]);
legend('Saturation','Noise Floor');
title(sname);

subplot(3,2,6);
dyn_range_dBV = y2_dB(:) - y_dB(:);
plot(in_gain_dB,dyn_range_dBV,'o-','linewidth',2);
xlabel('Input Gain (dB)');
ylabel({'Instant. Dynamic Range';...
    ['(dBVrms, ' num2str(f_lim_Hz(1)/1000) '-' num2str(f_lim_Hz(2)/1000) ' kHz)']});
hold on;
ylim([60 105]);
y=max(dyn_range_dBV);
plot(in_gain_dB([1 end]),y*[1 1],'k--','linewidth',2);
hold off;
text(in_gain_dB(end)-0.05*diff(xlim),y, ...
    [num2str(y,3) ' dBV'],'backgroundcolor','white',...
    'verticalalignment','middle','horizontalalignment','right');
title(sname);

