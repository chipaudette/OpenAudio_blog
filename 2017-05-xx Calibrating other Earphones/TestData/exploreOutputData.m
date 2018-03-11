

pname = 'BK_Data\';
addpath('..\..\MatlabFunctions\');

tympan_output_gain_dB = 0;
Volt_Pa=[];
data_type = 1;  %1 = Pa, 2=Volt
t_start_sec = [];
chan=1;
switch 101
    case 11
        fname = '11-SyntheticOutputSweep_0.0316V_PaA.wav';
        Volt_Pa = 0.0316;
        t_start_sec = 6.403 -1.0 - (3.7e-3)/2;
        drive_amplitude = [0.1 0.3 0.5 0.7 1.0]/2;
        earphone_type = 'Klipsch S4';
    case 101    
        fname = '101-Klipsch_0.0316V_PaA.wav';
        Volt_Pa = 0.0316;
        t_start_sec = 8.331 -1.0 - (3.7e-3)/2;
        drive_amplitude = [0.05 0.1 0.25 0.5 1.0];
        earphone_type = 'Klipsch S4'; 
        chan = 1;
    case 102    
        fname = '102-Etymotic_0.0316V_PaA.wav';
        Volt_Pa = 0.0316;
        t_start_sec = 7.723 -1.0 - (3.7e-3)/2;
        drive_amplitude = [0.05 0.1 0.25 0.5 1.0];
        earphone_type = 'Etymotic HF5'; 
        chan = 1;        
end

%define sweep params
params=[];
params.t_silence_sec = 1.0+3.7e-3/2;
params.t_sweep_sec = 10;
params.n_cycles = 5;
params.drive_amplitude = drive_amplitude;
params.lim_drive_ind = 3;  %index into vector above, where it starts to distort

addpath('..\functions\');

%calibrate
cal_scale_fac = 0.943;
if (0)
    cal_fname = '0-94dB_onEar_1V_PaA.wav';
    cal_SPL_dB = 94;
    cal_Volt_Pa = 1.0;
    disp(['loading ' pname cal_fname]);
    [wav_V,fs_Hz]=loadWavAndDat([pname cal_fname]);
    wav_V = wav_V(:,2);  %output is earphone is right channel
    [b,a]=butter(2,[100 8000]/(fs_Hz/2));
    wav_V = filter(b,a,wav_V);
    wav_Pa = wav_V * cal_scale_fac / cal_Volt_Pa;
    rms_Pa = sqrt(mean(wav_Pa.^2));
    disp(['measured SPL for cal = ' num2str(20*log10(rms_Pa/20e-6))]);
end

%read data
disp(['loading ' pname fname]);
[wav_V,fs_Hz]=loadWavAndDat([pname fname]);
wav_V = wav_V(:,chan);  %output is earphone is right channel
wav_Pa = wav_V * cal_scale_fac / Volt_Pa;

[b,a]=butter(2,60/(fs_Hz/2),'high');
wav_Pa = filter(b,a,wav_Pa);
if fs_Hz > 45000
    [b,a]=butter(4,[22000]/(fs_Hz/2));
    wav_Pa = filter(b,a,wav_Pa);
end

%check overall amplitude (good for testing using the calibraiton file)
rms_Pa = sqrt(mean(wav_Pa.^2));
ave_SPL_dB = 20*log10(rms_Pa/20e-6);
disp(['ave SPL (dB) = ' num2str(ave_SPL_dB)]);

%analyze data
[out]=f_measureSweeps(wav_Pa,fs_Hz,t_start_sec,params);

%% plots
figure;setFigureTallWide;ax=[];
subplot(2,2,1);
t_sec = ([1:length(wav_Pa)]-1)/fs_Hz;
dec_fac = 100;
plot(t_sec(1:dec_fac:end),wav_Pa(1:dec_fac:end));
xlim(t_sec([1 end]));xl=xlim;
xlabel('Time (sec)');
switch data_type
    case 1
        ylabel('Headphone Output (Pa)');
    case 2
        ylabel('Headphone Voltage (V)');
end
title(fname,'Interpreter','none');

t_sweep_sec = out.t_sweep_sec;
hold on
for I=1:size(t_sweep_sec,1);
    plot(t_sweep_sec(I,1)*[1 1],ylim,'g:');
    plot(t_sweep_sec(I,2)*[1 1],ylim,'r:');
end
hold off
    
subplot(2,2,2);
N=512; overlap=0.5;
norm_fac = 20e-6;cl = 120+[-100 0];
if (data_type==2); norm_fac = 1; cl = 0 + [-diff(cl) 0]; end
[pD,wT,f]=windowedFFTPlot_spectragram(wav_Pa/norm_fac,N,overlap,fs_Hz);
set(gca,'Clim',cl);
xlim(xl);
ylim([0 22000]);

subplot(2,2,3);
plot(t_sec(1:dec_fac:end),20*log10(out.wav_rms(1:dec_fac:end)/norm_fac));
xlim(xl);
xlabel('Time (sec)');
switch data_type
    case 1
        ylabel('Headphone Output (dB SPL)');
        ylim([50 120]+5);
    case 2
        ylabel('Headphone Voltage (dBV)');
end
title(fname,'Interpreter','none');

subplot(2,2,4);
semilogx(out.freq_Hz(1:dec_fac:end,:),20*log10(out.rms(1:dec_fac:end,:)/norm_fac));
xlabel('Frequency (Hz)');
xlim([100 10000]);
switch data_type
    case 1
        ylabel('Headphone Output (dB SPL)');
        ylim([50 120]+5);
    case 2
        ylabel('Headphone Voltage (dBV)');
end
title(fname,'Interpreter','none');

lt={};
for I=1:length(params.drive_amplitude);
    lt{end+1} = ['Amplitude = ' num2str(params.drive_amplitude(I))];
end
legend(lt,'location','southwest');

%% summary
figure;setFigureTallWide;
pos=get(gcf,'position');set(gcf,'position',[pos(1) pos(2) 1000 630]);

drive_dBFS = 20*log10(params.drive_amplitude/sqrt(2));
headphone_SPL_dB = 20*log10(out.targ_rms/norm_fac);

%txt = {['Earphones: ' earphone_type];['Tympan Output Gain: ' num2str(tympan_output_gain_dB) ' dB']};
txt1 = {[earphone_type ' Earphones'];['with 2cc Coupler']};
txt2 = {['Full Drive = -3dBFS'];
       ['Start Dist = -15dBFS']};

example_freq_Hz = [125 250 500 1000 2000 4000 8000];
plot_inds = [];
for I=1:length(example_freq_Hz)
    [foo,J]=min(abs(out.targ_freq_Hz - example_freq_Hz(I)));
    plot_inds(I) = J;
end

subplot(2,2,1);
plot(drive_dBFS,headphone_SPL_dB(plot_inds,:),'o-');
xlabel('Digital Drive Level (dBFS)');
xlim([-30 0]);
switch data_type
    case 1
        ylabel('Headphone Output (dB SPL)');
        ylim([50 120]+5);
    case 2
        ylabel('Headphone Voltage (dBV)');
end
lt={};for I=1:length(example_freq_Hz); lt{end+1}=[num2str(out.targ_freq_Hz(plot_inds(I))) 'Hz'];end;
legend(lt,'location','southeast');

subplot(2,2,3);
out_SPL_at_FS =  headphone_SPL_dB - drive_dBFS;
plot(drive_dBFS,out_SPL_at_FS(plot_inds,:),'o-');
xlabel('Digital Drive Level (dBFS)');
xlim([-30 0]);
switch data_type
    case 1
        ylabel('Headphone (dB SPL) at 0 dBFS Drive');
        ylim([80 135]);
    case 2
        ylabel('Headphone (dBV) at 0 dBFS Drive');
end
%legend(lt,'location','southeast');
hold on; plot(-3*[1 1],ylim,'k--','linewidth',2);hold off;
yl=ylim;
text(-3,yl(1)+0.05*diff(yl),{'Max';'Drive'},...
    'verticalalignment','bottom','horizontalalignment','center',...
    'backgroundcolor','white');


subplot(2,2,4);
max_dBSPL = headphone_SPL_dB(:,end)-drive_dBFS(end) - 3.0;
clean_dBSPL = headphone_SPL_dB(:,params.lim_drive_ind);
semilogx(out.targ_freq_Hz,max_dBSPL,'o-','linewidth',2,'markersize',4);
hold on;
semilogx(out.targ_freq_Hz,clean_dBSPL,'o-','linewidth',2,'markersize',4);
hold off;
xlim([100 10000]);
xlabel('Frequency (Hz)');
set(gca,'XTick',out.targ_freq_Hz);
set(gca,'XTick',[125 250 500 1000 2000 4000 8000 16000]);
ylabel({'Earphone Output (dB SPL)'});
ylim([85 135]+7.5);

legend({'Full Scale Drive','Start Distortion'},'location','northeast');
%title(fname,'interpreter','none');
title('Maximum Tympan Output');

weaText(txt1,2);
weaText(txt2,3);

[foo,I]=min(abs(out.targ_freq_Hz - 1000));
yl=ylim;
hold on;plot(out.targ_freq_Hz(I),max_dBSPL(I),'ko','linewidth',2,'markersize',6);hold off
text(out.targ_freq_Hz(I),max_dBSPL(I)+0.05*diff(yl), ...
    num2str(max_dBSPL(I),4), 'HorizontalAlignment','center',...
    'verticalAlignment','bottom');
hold on;plot(out.targ_freq_Hz(I),clean_dBSPL(I),'ko','linewidth',2,'markersize',6);hold off
text(out.targ_freq_Hz(I),clean_dBSPL(I)-0.05*diff(yl), ...
    num2str(clean_dBSPL(I),4), 'HorizontalAlignment','center',...
    'verticalAlignment','top');
%weaText('Using 2cc Coupler',4);



