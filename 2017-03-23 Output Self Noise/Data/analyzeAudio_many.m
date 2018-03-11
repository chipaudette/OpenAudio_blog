
cal_Tympan_V_atFS =  1.0*sqrt(2);
Tympan_max_V = 0.6*sqrt(2);
cal_TASCAM_V_atFS = sqrt(10.^(0.1*(-46 - (-57.1) - 1.8)));
out_gain_dB = [];

p_root1 = 'C:\Creare_Data\Cool Aid\Olympus Stuff\Data\20161022 Teensy 3.6 Self Noise (Home)\';
p_root2 = 'C:\Creare_Data\Cool Aid\Olympus Stuff\Data\20170223 CoolAid Pre-AAS conference\';


% plot all Tympan Cases
all_cases = [1:5]; 
summary_mode = 3; summary_types = {'Tympan (No USB)'};
%teensy_line_in = [0 5 10 15];
%teensy_gain_dB = 10*log10((3.12./[3.12 1.33 0.56 0.24]).^2);
tympan_gain_dB = [-20 -10 0 10 20];
all_gain_dB = [tympan_gain_dB(:);];
max_out_Vrms = [ [cal_Tympan_V_atFS / sqrt(2) .* sqrt(10.^(0.1*tympan_gain_dB(:)))]; ];
max_out_Vrms = min(max_out_Vrms,Tympan_max_V);
summary_xlt={};


cal_V_atFS = cal_TASCAM_V_atFS;

%%
flag_plot_tones=0;
for Icase = 1:length(all_cases)
    
    pname = 'Tympan_viaTascamDR-40\';
    
    fname = 'TASCAM_GAIN24_NoUSB.wav';
    if (flag_plot_tones == 0)
        %silence
        t_start_sec =  21.531;
        sname = 'Tympan Output Self-Noise, No USB';
    else
        %tones
        t_start_sec = 6.200;
        sname = 'Tympan Output, 0.01 Tone, No USB';
    end
    out_gain_dB = [-20 -10 0 10 20];
    gain_dur_sec = 3.046;
    %s_sname = 'Tympan, Shorted';'USB Audio';
    s_sname = {'Tympan';'Headphone Out';'No USB'};
            

    switch all_cases(Icase);
            
        case 1
            ind = 1;
            sname = [sname ', Gain ' num2str(out_gain_dB(ind)) ' dB'];
            t_lim_sec = t_start_sec + gain_dur_sec*[ind-1 ind]+[0.2 -0.2]; out_gain_dB = out_gain_dB(ind);
            %cal_V_atFS = cal_Tympan_V_atFS / sqrt(10.^(0.1*out_gain_dB));  %from pre-AAS testing
            
        case 2
            ind = 2;
            sname = [sname ', Gain ' num2str(out_gain_dB(ind)) ' dB'];
            t_lim_sec = t_start_sec + gain_dur_sec*[ind-1 ind]+[0.2 -0.2]; out_gain_dB = out_gain_dB(ind);
            %cal_V_atFS = cal_Tympan_V_atFS / sqrt(10.^(0.1*out_gain_dB));  %from pre-AAS testing
           
        case 3
            ind = 3;
            sname = [sname ', Gain ' num2str(out_gain_dB(ind)) ' dB'];
            t_lim_sec = t_start_sec + gain_dur_sec*[ind-1 ind]+[0.2 -0.2]; out_gain_dB = out_gain_dB(ind);
            %cal_V_atFS = cal_Tympan_V_atFS / sqrt(10.^(0.1*out_gain_dB));  %from pre-AAS testing
         case 4
            ind = 4;
            sname = [sname ', Gain ' num2str(out_gain_dB(ind)) ' dB'];
            t_lim_sec = t_start_sec + gain_dur_sec*[ind-1 ind]+[0.2 -0.2]; out_gain_dB = out_gain_dB(ind);
            %cal_V_atFS = cal_Tympan_V_atFS / sqrt(10.^(0.1*out_gain_dB));  %from pre-AAS testing
        case 5
            ind = 5;
            sname = [sname ', Gain ' num2str(out_gain_dB(ind)) ' dB'];
            t_lim_sec = t_start_sec + gain_dur_sec*[ind-1 ind]+[0.2 -0.2]; out_gain_dB = out_gain_dB(ind);
            %cal_V_atFS = cal_Tympan_V_atFS / sqrt(10.^(0.1*out_gain_dB));  %from pre-AAS testing
         
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
    wav = wav(:,1);
    
    
    
    %% process data
    %cal_V_per_count = cal_Tympan_V_per_count / sqrt(10.^(0.1*in_gain_dB));  %from pre-AAS testing
    Nfft = 2*round(0.125*fs_Hz);
    if (1)
        bp_Hz = [125 8000];bp_txt = [num2str(bp_Hz(1)) '-' num2str(bp_Hz(2)) ' Hz'];
    else
        bp_Hz = 'A-weight'; bp_txt = ['A-weighted'];
    end
    [rms_wav,ave_spec,freq_Hz,proc_wavs]=f_analyzeWav(wav, fs_Hz, bp_Hz, t_lim_sec,cal_V_atFS, Nfft);
    t_sec = ([1:size(proc_wavs.wav,1)]-1)/fs_Hz;
    
    %accumulate
    if (Icase == 1)
        all_rms_wav = rms_wav;
        all_spec = ave_spec;
        all_freq_Hz={}; all_freq_Hz{1} = freq_Hz;
        all_snames={};all_snames{end+1} = sname;
        all_s_snames={}; all_s_snames{end+1} = s_sname;
        all_V_atFs=cal_V_atFS;
        max_realizable_output_Vrms = max_out_Vrms(Icase);
    else
        all_rms_wav(Icase) = rms_wav;
        all_spec(Icase) = ave_spec;
        all_freq_Hz{Icase} = freq_Hz;
        all_snames{Icase} = sname;
        all_s_snames{Icase} = s_sname;
        all_V_atFs(Icase) = cal_V_atFS;
        max_realizable_output_Vrms(Icase) = max_out_Vrms(Icase);
    end
    
    
    %% plots
    figure;setFigureTallWide;ax=[];
    nrow=2;ncol=2;
    subplot(nrow,ncol,1);
    dec_fac = 10;
    plot(t_sec(1:dec_fac:end),proc_wavs.wav(1:dec_fac:end,:));
    xlabel('Time (sec)');
    ylabel({'Recorded Value';'(from USB or SD)'});
    title(sname,'interpreter','none');
    ylim([-1 1]);
    xlim(t_sec([1 end]));
    ax(end+1) = gca;
    
    
    subplot(nrow,ncol,2);
    res_Hz = 10;  %approximate desired resolution
    N = 2*round(0.5*fs_Hz/res_Hz); overlap=0.75;
    plots = 0;
    [pD,wT,f]=windowedFFTPlot_spectragram(proc_wavs.wav_mr,N,overlap,fs_Hz,plots);
    wT = wT + (N/2)/fs_Hz;
    imagesc(wT,f/1000,10*log10(pD));
    set(gca,'Ydir','normal');
    xlabel('Time (sec)');
    ylabel('Frequency (kHz)');
    title('Power Spectral Density (dB/bin)')
    set(gca,'Clim',10*log10(1/N)+[-100 0]);
    xlim(t_sec([1 end]));
    ylim([0 20000]/1000);
    ax(end+1) = gca;
    
    subplot(nrow,ncol,3);
    semilogx(freq_Hz, 20*log10(ave_spec.counts_sqrtHz));
    %legend(t_name);
    xlabel('Frequency (Hz)');
    ylabel('dB re: FS/sqrt(Hz)');
    xlim([10 20000]);
    set(gca,'Xtick',[10 100 1000 10000],'XTickLabels',{'10' '100' '1K' '10K'});
    ylim([-140 0]);
    title(sname,'interpreter','none');
    weaText({['fs = ' num2str(fs_Hz/1000) ' kHz'];
        ['Nfft = ' num2str(Nfft)]},2);
    
    
    subplot(nrow,ncol,4);
    semilogx(freq_Hz, 20*log10(ave_spec.V_sqrtHz));
    %legend(t_name);
    xlabel('Frequency (Hz)');
    ylabel('dB re: 1 V/sqrt(Hz)');
    xlim([10 20000]);
    set(gca,'Xtick',[10 100 1000 10000],'XTickLabels',{'10' '100' '1K' '10K'});
    ylim([-130 -20]);
    title(sname,'interpreter','none');
    weaText({['fs = ' num2str(fs_Hz/1000) ' kHz'];
        ['Nfft = ' num2str(Nfft)]},2);
    
    linkaxes(ax,'x');
    
end

%% plot comparisons
figure;setFigureTallWide;

subplot(2,2,1);
all_rms_fwav_V = [all_rms_wav(:).fwav_Vrms];
x = [1:length(all_rms_fwav_V)];
type=[];
ndata = length(all_rms_fwav_V);
if summary_mode == 1
    lt={};
    for I=1:ndata
        s_sname = all_s_snames{I};
        sname = s_sname{1};
        if strcmpi(sname(1:length('Teensy')),'Teensy')
            type(I)=1;
        else
            type(I)=2;
        end
    end
    summary_xlt = all_s_snames;
elseif summary_mode == 2
    type(1:ndata) = 1;
    type(ndata/2+1:end) = 2;
    x(ndata/2+1:end) = x(1:ndata/2);
end

for Itype=1:2
    I=find(type==Itype);
    plot(x(I),20*log10(all_rms_fwav_V(I)),'o-','linewidth',2);
    hold on;
end
hold off;
box on
xlim([min(x) max(x)]+0.5*[-1 1]);
ylabel({'Self Noise, Headphone Output';['(dBVrms, ' bp_txt ')']});
set(gca,'Xtick',unique(x),'XtickLabels',[]);
title('Measured Self Noise, Headphone Output');
%ylim([-120 -60]);
for I=1:length(summary_xlt);
    yl=ylim;
    h = text(x(I),yl(1)-0.04*diff(yl), summary_xlt{I}, ...
        'Rotation',90,'VerticalAlignment','middle','horizontalAlignment','right');
end
if (summary_mode == 2); legend(summary_types);end

subplot(2,2,2);
dyn_range_dBV = 20*log10((all_V_atFs/sqrt(2))./all_rms_fwav_V);
for Itype=1:2
    I=find(type==Itype);
    plot(x(I),dyn_range_dBV(I),'o-','linewidth',2);
    hold on;
end
hold off;
box on
xlim([min(x) max(x)]+0.5*[-1 1]);
ylim([60 100]);
ylabel({'Dynamic Range, Input';['(dB, ' bp_txt ')']});
set(gca,'Xtick',unique(x),'XtickLabels',[]);
for I=1:length(summary_xlt);
    yl=ylim;
    h = text(x(I),yl(1)-0.04*diff(yl), summary_xlt{I}, ...
        'Rotation',90,'VerticalAlignment','middle','horizontalAlignment','right');
end
title('Instantaneous Dynamic Range of Input');
if (summary_mode == 2); legend(summary_types);end

%% same plot but with quantitative x-axis
if summary_mode == 3
    figure;setFigureTallWide;
    subplot(2,2,1);
    x = max_out_Vrms(:);
    all_rms_fwav_V = [all_rms_wav(:).fwav_Vrms];
    type=[];
    ntypes = length(summary_types);
    for I=1:ntypes;
        type = [type(:); I*ones(size(x,1)/ntypes,1)];
    end
    for Itype=1:ntypes
        I=find(type==Itype);
        semilogx(x(I),20*log10(all_rms_fwav_V(I)),'o-','linewidth',2);
        hold on;
    end
    hold off;
    box on
    ylim([-100 0]);yl_noise_dB = ylim;
    ylabel({'Self Noise, Headphone Output';['(dBVrms, ' bp_txt ')']});
    xlim([0.01 1.5]);
    xlabel('Max Realizable Output (Vrms) for Gain Setting');
    set(gca,'XTick',[0.01 0.03 0.1 0.3 1.0],'XTIckLabel',{'0.01' '0.03' '0.1' '0.3' '1.0'});
    title('Measured Self Noise, Headphone Output');
    legend(summary_types,'location','northwest');
    
    
    yl=ylim;
    y = 20*log10(all_rms_fwav_V);
%    I=find(type == 1);
%     for J=1:length(I);
%         text(x(I(J)),y(I(J))+0.05*diff(yl),{['In ' num2str(teensy_line_in(J))]}, ...
%             'verticalalignment','bottom','horizontalalignment','center');
%     end    
    I=find(type == ntypes);
    for J=1:length(I);
        %if J > 2
        %    text(x(I(J)),y(I(J))+0.05*diff(yl),{'Gain';[num2str(tympan_gain_dB(J)) 'dB']}, ...
        %        'verticalalignment','bottom','horizontalalignment','center');
        %else 
            text(x(I(J)),y(I(J))-0.03*diff(yl),{'Gain';[num2str(tympan_gain_dB(J)) 'dB']}, ...
                'verticalalignment','top','horizontalalignment','center');
        %end
    end

    
    subplot(2,2,2);
    dyn_range_dBV = 20*log10(max_realizable_output_Vrms./all_rms_fwav_V);
    for Itype=1:ntypes
        I=find(type==Itype);
        semilogx(x(I),dyn_range_dBV(I),'o-','linewidth',2);
        hold on;
    end
    hold off;
    box on
    ylim([50 100]);
    ylabel({'Dynamic Range of Output';['(dB, ' bp_txt ')']});
    xlim([0.01 1.5]);
    xlabel('Max Realizable Output (Vrms) for Gain Setting');
    set(gca,'XTick',[0.01 0.03 0.1 0.3 1.0],'XTIckLabel',{'0.01' '0.03' '0.1' '0.3' '1.0'});
    title('Instantaneous Dynamic Range of Input');
    legend(summary_types,'location','southeast');
    

    yl=ylim;
    y = dyn_range_dBV;
    I=find(type == 1);
    for J=1:length(I);
        text(x(I(J)),y(I(J))+0.05*diff(yl),[num2str(y(I(J)),3)], ...
            'verticalalignment','bottom','horizontalalignment','center');
    end
    I=find(type == ntypes);
    for J=1:length(I);
        text(x(I(J)),y(I(J))+0.05*diff(yl),[num2str(y(I(J)),3)], ...
            'verticalalignment','bottom','horizontalalignment','center');
    end
end


subplot(2,2,3);
all_rms_fwav_V = [all_rms_wav(:).fwav_Vrms];
x = all_gain_dB; y = 20*log10(all_rms_fwav_V);
plot(x,y,'o-','linewidth',2);
xlabel('Output Gain (dB)');
xlim([min(x) max(x)] + [-5 5]);
ylim(yl_noise_dB);
ylabel({'Self Noise, Headphone Output';['(dBVrms, ' bp_txt ')']});
title('Measured Self Noise, Headphone Output');
legend(summary_types,'location','northwest');
I=find(type == ntypes);
for J=1:length(x)
    text(x(J),y(J)+0.05*diff(yl),[num2str(y(J),3)], ...
        'verticalalignment','bottom','horizontalalignment','center');
end

subplot(2,2,4);
x = all_gain_dB; y = dyn_range_dBV;
plot(x,y,'o-','linewidth',2);
xlabel('Output Gain (dB)');
xlim([min(x) max(x)] + [-5 5]);
ylim([50 100]);
ylabel({'Dynamic Range of Output';['(dB, ' bp_txt ')']});
title('Instantaneous Dynamic Range of Headphone Output');
legend(summary_types,'location','northwest');
I=find(type == ntypes);
for J=1:length(x)
    text(x(J),y(J)+0.05*diff(yl),[num2str(y(J),3)], ...
        'verticalalignment','bottom','horizontalalignment','center');
end


%% more plots
if summary_mode == 1
    figure;setFigureTallPartWide;
    c=lines;
    for I=1:length(all_spec)
        if I < 3
            subplot(3,2,I)
        elseif I==3
            subplot(3,4,4+[2 3]);
        else
            subplot(3,2,I+1);
        end
        spec = all_spec(I);
        freq_Hz = all_freq_Hz{I};
        semilogx(freq_Hz,20*log10(spec.V_sqrtHz),'color',c(type(I),:),'linewidth',2);
        ylim([-160 -80]);
        hold on;
        s_snames = all_s_snames{I};
        title([s_snames{1} ', ' s_snames{2} ', ' s_snames{3}]);
        ylim([-160 -80]);
        xlabel('Frequency (Hz)');
        xlim([10 20000]);
        set(gca,'Xtick',[10 100 1000 10000],'XTickLabels',{'10' '100' '1K' '10K'});
        ylabel({'Noise Density';'dB re: 1 V/sqrt(Hz)'})
        hold on;
        yl=ylim;
        y = 20*log10(all_rms_wav(I).fwav_Vrms);
        %y_perHz = 10*log10(10.^(0.1*y)/diff(bp_Hz));
        if isnumeric(bp_Hz)
            plot(bp_Hz(1)*[1 1],yl,'k--','linewidth',2);
            plot(bp_Hz(2)*[1 1],yl,'k--','linewidth',2);
            x_txt = exp(mean(log(bp_Hz)));
            note_txt = {['Sum = ' num2str(y,3) ' dBV']};
        else
            x_txt = exp(mean(log(xlim)));
            note_txt = {'A-Weighted Sum:';[ num2str(y,3) ' dBV']};
        end
        text(x_txt,yl(2)-0.05*diff(yl), ...
            note_txt, ...
            'verticalalignment','top','horizontalalignment','center');
        hold off
    end    
end


