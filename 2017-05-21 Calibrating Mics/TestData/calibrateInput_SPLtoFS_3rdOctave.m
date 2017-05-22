


pname_truth = 'BK_Data\';
pname = 'SD_Card\';

addpath('..\..\MatlabFunctions\');
addpath('..\..\MatlabFunctions\OctaveBandFilters\');

for Icase = [3 1 2]
%for Icase = [2]
    
    
    tympan_output_gain_dB = 0;
    %earphone_type = 'Klipsch S4';
    tympan_input_gain_dB = [0 10 20 30 40];
    data_type = 1;  %1 = Pa, 2=Volt
    t_start_sec = 0;
    switch Icase
        %case 0
        %    fname = '0-94dB_onEar_1V_PaA.wav';
        %    t_start_sec = 0;
        %    Volt_Pa = 1.0;
        case 1
            fname_true = '07-SonyMic_TestSig_1V_PaA.wav';
            t_start_true_sec =  3.9;  %23.694; %start in a noise segment
            Volt_Pa = 1.0;
            fname = '07-SonyMic_TestSigs.raw';
            t_start_sec =   17.390;
            mic_type = 'Sony Mic';
            out_fname = 'MATs\cal_sony_3rdOctave.mat';
        case 2
            fname_true = '13-KnowlesMic_TestSig_0.316V_PaA.wav';
            Volt_Pa = 0.316;
            t_start_true_sec = 2.85;  %[21.55]; %noise
            fname = '10-KnowesMic_TestSigs.raw';
            t_start_sec = 17.112;
            mic_type = 'Knowles Mic';
            out_fname = 'MATs\cal_knowles_3rdOctave.mat';
        case 3
            fname_true = '14-PCBMics-TestSigs_1V_PaA.wav';
            t_start_true_sec = 2.6;  %22.034;
            Volt_Pa = 1.0;
            fname = '14-PCBMic_TestSig.raw';
            t_start_sec =   15.905;
            mic_type = 'PCB Mic';
            out_fname = 'MATs\cal_PCB_3rdOctave.mat';
    end
    
    
    %addpath('..\functions\');
    
    % %calibrate
    cal_scale_fac = 0.943;
    if (0)
        cal_fname = '0-94dB_onEar_1V_PaA.wav';
        cal_SPL_dB = 94;
        disp(['loading ' pname cal_fname]);
        [wav_V,fs_Hz]=loadWavAndDat([pname cal_fname]);
        wav_V = wav_V(:,2);  %output is earphone is right channel
        [b,a]=butter(2,[100 8000]/(fs_Hz/2));
        wav_V = filter(b,a,wav_V);
        wav_V = wav_V * cal_scale_fac;
        wav_Pa = wav_V / Volt_Pa;
        rms_Pa = sqrt(mean(wav_Pa.^2));
        disp(['measured SPL for cal = ' num2str(20*log10(rms_Pa/20e-6))]);
    end
    
    %read true data
    disp(['loading ' pname_truth fname_true]);
    [wav_true_V,fs_true_Hz]=loadWavAndDat([pname_truth fname_true]);
    wav_true_V = wav_true_V(:,1);  %left channel is room mic
    wav_true_Pa = wav_true_V * cal_scale_fac / Volt_Pa;
    
    %read SD data
    disp(['reading ' pname fname]);
    fid = fopen([pname fname]);
    wav_V = fread(fid,'int16')/(2^15);
    wav_V = wav_V - mean(wav_V);
    fs_Hz = 44100;
    
    %resample
    [N,D]=rat(fs_true_Hz/fs_Hz);
    wav_V = resample(wav_V,N,D);
    fs_Hz = fs_true_Hz;
    
    %join the datasets
    t_offset_sec = max([-5 -t_start_true_sec]);
    wav_true_Pa = wav_true_Pa((round((t_start_true_sec+t_offset_sec)*fs_true_Hz)+1):end);
    wav_V = wav_V((round((t_start_sec+t_offset_sec)*fs_Hz)+1):end);
    len=min([length(wav_true_Pa) length(wav_V)]);
    wav_Pa = [wav_true_Pa(1:len) wav_V(1:len)];
    
    
    %assess every noise period
    t_win = [0 0.42];
    t_period_sec = 3.0;
    n_test = length(tympan_input_gain_dB);
    norm_fac = [20e-6 1];  %SPL and Volts
    [sig_in_dBSPL,sig_out_dB,freq_Hz] = f_measureNoisePeriods_3rdOctave(wav_Pa,fs_Hz,n_test,t_offset_sec,t_period_sec,t_win,norm_fac);
    scale_dBFS_94dBSPL = sig_out_dB-sig_in_dBSPL+94;
    
    targ_freq = 1000;
    [foo,I]=min(abs(freq_Hz - targ_freq));
    scale_dBFS_94dBSPL_1kHz = scale_dBFS_94dBSPL(I,:);
    
    clip_dBFS = 20*log10(1/sqrt(2));
    scale_dBSPL_1kHz_at_clip = clip_dBFS-scale_dBFS_94dBSPL_1kHz+94;
    
    disp(['saving data to ' out_fname]);
    save(out_fname,'scale_dBFS_94dBSPL','scale_dBFS_94dBSPL','fs_Hz','mic_type','tympan_input_gain_dB','freq_Hz','scale_dBFS_94dBSPL_1kHz','scale_dBSPL_1kHz_at_clip','clip_dBFS');
    
    %% spectrogram
    if (0)
        figure;setFigureTallPartWide;
        pos=get(gcf,'position');set(gcf,'position',[pos(1) pos(2) 800 475]);
        for Ichan=1:size(wav_Pa,2)
            subplot(2,1,Ichan);
            N=512*2;overlap=0;
            inds = [round((-t_offset_sec-2.35)*fs_Hz):size(wav_Pa,1)];
            %inds = [1:size(wav_Pa,1)];
            [pD,wT,f]=windowedFFTPlot_spectragram(wav_Pa(inds,Ichan)/norm_fac(Ichan),N,overlap,fs_Hz);
            imagesc(wT,f/1e3,10*log10(pD));
            ylim([0 16]);
            set(gca,'Ydir','normal');
            xlabel('Time (sec)');
            ylabel('Frequency (kHz)');
            title('Power Spectral Density (dB/bin)')
            cl=get(gca,'Clim');set(gca,'Clim',cl(2)+[-80 0]);
            if (Ichan==1)
                title(['"Truth" Microphone (B&K 4191)']);
                xlabel('');
            else
                title([mic_type ', Digital Recording from Tympan']);
            end
            
        end
        
        for Iperiod=1:n_test
            hold on;
            x=t_period_sec*Iperiod;
            if (Iperiod < n_test)
                plot(x*[1 1],ylim,'w--','linewidth',2);
            end
            yl=ylim;
            text(x-0.5*t_period_sec,yl(2)-0.05*diff(yl),...
                {[num2str(tympan_input_gain_dB(Iperiod)) 'dB'];'Gain'},...
                'VerticalAlignment','Top','HorizontalAlignment','center',...
                'color',[1 1 1],'FontWeight','Bold');
            hold off;
        end
        
    end
    %%
    lt={};
    for I=1:length(tympan_input_gain_dB)
        lt{end+1}=[num2str(tympan_input_gain_dB(I)) 'dB Gain'];
    end
    
    figure;setFigureTallerWide;
    pos=get(gcf,'position');set(gcf,'position',[pos(1) pos(2) 910 700]);
    subplot(3,2,1);
    semilogx(freq_Hz,sig_in_dBSPL,'linewidth',2);
    xlim([100 20000]);
    ylim([20 100]);
    title('Truth Mic (B&K 4191)');
    ylabel('SPL (dB)');
    xlabel('3rd Octave Band (Hz)');set(gca,'XTick',[125 250 500 1000 2000 4000 8000 16000]);
    
    signal_txt = 'White Noise into Chamber';
    %fft_txt = {['fs = ' num2str(fs_Hz/1000) ' kHz, ' ...
    %    'Nfft = ' num2str(N)]};
    %weaText(fft_txt,3);
    weaText(signal_txt,2);
    
    subplot(3,2,2);
    semilogx(freq_Hz,sig_out_dB,'linewidth',2);
    xlim([100 20000]);
    ylim([-120 -20]);
    title({['Tympan Digital Recording with ' mic_type]});
    ylabel('dBFS (dB)');
    xlabel('3rd Octave Band (Hz)');set(gca,'XTick',[125 250 500 1000 2000 4000 8000 16000]);
    %weaText(fft_txt,3);
    weaText(signal_txt,4);
    weaText(['Gain Stepped ' num2str(min(tympan_input_gain_dB)) ' - ' num2str(max(tympan_input_gain_dB)) ' dB'],2);
    
    subplot(3,2,3);
    semilogx(freq_Hz,scale_dBFS_94dBSPL,'linewidth',2);
    xlim([100 20000]);
    ylabel({'Mic+Tympan Scale Factor';'(dBFS at 94 dB SPL)'});
    title(['Tympan Scale Factor with ' mic_type ]);
    xlabel('3rd Octave Band (Hz)');set(gca,'XTick',[125 250 500 1000 2000 4000 8000 16000]);
    ylim([-80 10]+15);
    %hold on;plot(xlim,-3*[1 1],'k--','linewidth',2);hold off;
    h=legend(lt,'location','southeast');
    try;moveLegendToSide(h);catch;end
    %weaText(fft_txt,4);
    weaText(signal_txt,2);
    
    subplot(3,2,5);
    h=plot(tympan_input_gain_dB,scale_dBFS_94dBSPL_1kHz,'o-','linewidth',2);
    xlabel('Tympan Input Gain (dB)');
    ylabel({'Scale Factor at 1kHz';'(dBFS at 94 dB SPL)'});
    title(['Tympan Scale Factor with ' mic_type ]);
    ylim([-60 20]);
    targ_gain = 20;
    I=find(tympan_input_gain_dB==targ_gain);val = scale_dBFS_94dBSPL_1kHz(I);
    yl=ylim;
    hold on; plot(tympan_input_gain_dB(I),scale_dBFS_94dBSPL_1kHz(I),'o-','linewidth',2,'color',get(h,'color'),'markerfacecolor',get(h,'color'));
    text(targ_gain,val+0.075*diff(yl),[num2str(val,3) ' dBFS'],...
        'verticalalignment','bottom','horizontalalignment','center');
    text(targ_gain,val-0.075*diff(yl),['at 94 dBSPL'],...
        'verticalalignment','top','horizontalalignment','center');
    
    subplot(3,2,6);
    h=plot(tympan_input_gain_dB,scale_dBSPL_1kHz_at_clip,'o-','linewidth',2);
    xlabel('Tympan Input Gain (dB)');
    ylabel({'SPL at Clip';'at 1kHz (dB)'});
    title(['Tympan Max Input with ' mic_type]);
    ylim([0 100]+50);
    targ_gain = 20;
    I=find(tympan_input_gain_dB==targ_gain);val = scale_dBSPL_1kHz_at_clip(I);
    yl=ylim;
    hold on; plot(tympan_input_gain_dB(I),scale_dBSPL_1kHz_at_clip(I),'o-','linewidth',2,'color',get(h,'color'),'markerfacecolor',get(h,'color'));
    text(targ_gain,val+0.075*diff(yl),[num2str(val,3) ' dBSPL'],...
        'verticalalignment','bottom','horizontalalignment','center');
    text(targ_gain,val-0.075*diff(yl),['at Clipping'],...
        'verticalalignment','top','horizontalalignment','center');
    weaText(['Clips at ' num2str(clip_dBFS,2) ' dBFS'],4);
    
end

