
all_max_dBSPL=[];
all_names = {};
all_scale_dBFS_94dBSPL=[];
for Icase = [1 3 2];
    
    switch Icase
        case 1
            mic_type = 'Sony Mic';
            cal_fname = 'MATs\cal_sony_3rdOctave.mat';
        case 2
            mic_type = 'Knowles Mic';
            cal_fname = 'MATs\cal_knowles_3rdOctave.mat';
        case 3
            mic_type = 'PCB Mic';
            cal_fname = 'MATs\cal_PCB_3rdOctave.mat';
    end
    
    %load cal data
    cal_data = load(cal_fname);
    cal_scale_fac = 0.943;
 
    %parse data
    tympan_input_gain_dB = cal_data.tympan_input_gain_dB;
    all_max_dBSPL(:,end+1) = cal_data.scale_dBSPL_1kHz_at_clip(:);
    
    scale_dBFS_at0dB_at94dBSPL = cal_data.scale_dBFS_94dBSPL - (ones(size(cal_data.scale_dBFS_94dBSPL,1),1)*cal_data.tympan_input_gain_dB);
    scale_dBFS_at0dB_at94dBSPL = median(scale_dBFS_at0dB_at94dBSPL')';
    all_scale_dBFS_94dBSPL(:,end+1) = scale_dBFS_at0dB_at94dBSPL;
    freq_Hz = cal_data.freq_Hz;
    
    all_names{end+1} = mic_type;
end

%% plots
lt={};
for I=1:length(tympan_input_gain_dB)
    lt{end+1}=[num2str(tympan_input_gain_dB(I)) 'dB Gain'];
end

figure;setFigureTallWide;
pos=get(gcf,'position');set(gcf,'position',[pos(1) pos(2) 1000 630]);
subplot(2,2,1);
semilogx(freq_Hz,all_scale_dBFS_94dBSPL,'o-','linewidth',2,'markersize',4);
xlim([100 20000]);set(gca,'XTick',[125 250 500 1000 2000 4000 8000 16000]);
xlabel('3rd Octave Band (Hz)');
ylabel({'Digital Value (dBFS)';'for 94 dBSPL at 0 dB Gain'});
title('Calibration of Tympan Input (Mic+ADC)');
legend(all_names,'location','southeast');

targ_freq_Hz = 1000;
[foo,I]=min(abs(freq_Hz - targ_freq_Hz));
hold on;plot(targ_freq_Hz,all_scale_dBFS_94dBSPL(I,:),'ko','linewidth',2,'markersize',4);hold off
for Imic=1:size(all_scale_dBFS_94dBSPL,2);
    val = all_scale_dBFS_94dBSPL(I,Imic);
    txt = [num2str(val,3) ' dBFS'];
    yl=ylim;
    if Imic==1
        text(targ_freq_Hz,val-0.05*diff(yl),txt,...
            'horizontalalignment','center','verticalAlignment','top');
    else
        text(targ_freq_Hz,val+0.05*diff(yl),txt,...
            'horizontalalignment','center','verticalAlignment','bottom');
    end
end
