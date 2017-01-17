

orig_pname = 'InputSignals\';
pname = 'OutputSignals\';
t_lim_sec=[];
trim_sec=0;
cr_test_sec=[];
orig_fname=[];
switch 21
    case 11
        pname = [pname 'Fast Compressor\'];
        t_lim_sec = [0 5];
        trim_sec = 0.136+0.005+0.005;
        cr_test_sec = [3.95 4.95];
        fname = 'ampSteps_-6_-31dB.wav';  cr_input_dBFS = [-31 -6];
        orig_fname = ['input_' fname];
        comp_ratio = 5;  thresh_dBFS = -15;
        ar_msec = [5 200];
    case 12
        pname = [pname 'Med Compressor\'];
        fname = 'ampSteps_-6_-31dB.wav';
        t_lim_sec = [0 5];
        trim_sec = 0.136+0.0053;
        cr_test_sec = [3.8 4.8];
        cr_input_dBFS = [-25 0]-6;
    case 13
        pname = [pname 'Slow Compressor\'];
        fname = 'Long_ampSteps_-6_-31dB.wav';
        t_lim_sec = [0 50];
        trim_sec = 0.138+2.5e-3;
        cr_test_sec = [39.5 49.5];
        cr_input_dBFS = [-31 -6];
        
        orig_fname = ['input' fname];
        comp_ratio = 5;  thresh_dBFS = -50;
        ar_msec = [1000 2000];
        
    case 21
        pname = [pname 'Fast Compressor\'];
        fname = 'ampSweep_-56_-6dB.wav';
        t_lim_sec = [0 10];
        trim_sec = 0.136;
        cr_test_sec = [8.5 9.5]+0.2;
        cr_input_dBFS = -50+cr_test_sec/10*50;
        
        orig_fname = ['input_' fname];
        comp_ratio = 5;  thresh_dBFS = -15;
        ar_msec = [5 200];
    case 22
        pname = [pname 'Med Compressor\'];
        fname = 'Long_ampSweep_-50_0dB.wav';
        t_lim_sec = [0 50];
        trim_sec = 0.136;
        cr_test_sec = [30 45];
        cr_input_dBFS = -50+cr_test_sec/50*50;
    case 23
        pname = [pname 'Slow Compressor\'];
        fname = 'Long_ampSweep_-56_-6dB.wav';
        t_lim_sec = [0 50];
        trim_sec = 0.136;
        cr_test_sec = [20 40];
        cr_input_dBFS = -50+cr_test_sec/50*50;
        
        orig_fname = ['input' fname];
        comp_ratio = 5;  thresh_dBFS = -50;
        ar_msec = [1000 2000];
end

% load WAV
disp(['loading ' pname fname])
[wav,fs_Hz]=audioread([pname fname]);
if ~isempty(orig_fname);
    disp(['loading ' orig_pname orig_fname]);
    [orig_wav]=audioread([orig_pname orig_fname]);
else
    orig_wav=zeros(size(wav));
end

%prepare data
wav = wav(:,1);  %keep first channel only
inds = [round(trim_sec*fs_Hz)+1 length(wav)];
wav = wav(inds(1):inds(2));
wav = wav - mean(wav);
comp_wav = wav;


%make the same length
if length(orig_wav) > length(comp_wav)
    orig_wav = orig_wav(1:length(comp_wav));
else
    comp_wav = comp_wav(1:length(orig_wav));
end

% plot;
figure;ax=[];
set(gcf,'position',[520   222   816   576]);
dec_fac = 1;

c=lines;
foo_amp_dB=[];
for Iplot=1:2
    switch Iplot
        case 1
            wav = orig_wav;
            tt = 'Sent to Teensy';
        case 2
            wav = comp_wav;
            tt = 'From Teensy';
    end
    t_sec = ([1:length(wav)]-1)/fs_Hz;
    
    subplot(2,2,Iplot);
    plot(t_sec(1:dec_fac:end),wav(1:dec_fac:end),'color',c(Iplot,:));
    if ~isempty(t_lim_sec);xlim(t_lim_sec);end;
    xlabel('Time (sec)');
    ylim([-1 1]);
    title(['Audio ' tt],'Interpreter','none');
    ylabel('Value Re: Full-Scale');
    %h=weaText(fname,2);set(h,'interpreter','none');
    if Iplot==2
        weaText(['CR = ' num2str(comp_ratio) ':1, Knee = ' num2str(thresh_dBFS) ' dBFS'],2);
        weaText(['Attack = ' num2str(ar_msec(1)) ' ms, Release = ' num2str(ar_msec(2)) ' ms'],4);
    end
    ax(end+1)=gca;
    
    
    % extract amplitude (dB)
    if (0)
        hwav = hilbert(wav);
        amp_dB = 20*log10(abs(hwav));
    else
        wavpow = wav.^2;
        lp_Hz = 2000/10;
        lp_Hz = 1000;
        lp_N = 2*round(0.5*fs_Hz/lp_Hz);
        a = 1;
        b = 1/lp_N*ones(lp_N,1);
        wavpow = filter(b,a,wavpow);
        
        %remove filter latency
        wavpow = [wavpow((lp_N/2+1):end); wavpow(end)*ones(lp_N/2,1)];
        
        amp_dB = 10*log10(wavpow);
    end
    
    % evaluate metrics
    if ~isempty(cr_test_sec)
        inds = round(cr_test_sec*fs_Hz);
        cr_output_dBFS = amp_dB(inds);
        apparent_CR = diff(cr_input_dBFS)./diff(cr_output_dBFS)
    end
    
    
    
    subplot(2,2,2+Iplot);
    plot(t_sec(1:dec_fac:end),amp_dB(1:dec_fac:end),'color',c(Iplot,:));
    if ~isempty(t_lim_sec);xlim(t_lim_sec);end;
    ylim([-55 5]);
    title(['Amplitude of Audio ' tt])
    ax(end+1)=gca;
    xlabel('Time (sec)');
    ylabel('Amplitude (dBFS)');
    if Iplot==2
        weaText(['CR = ' num2str(comp_ratio) ':1, Knee = ' num2str(thresh_dBFS) ' dBFS'],2);
        weaText(['Attack = ' num2str(ar_msec(1)) ' ms, Release = ' num2str(ar_msec(2)) ' ms'],4);
    end
    %     if ~isempty(cr_test_sec)
    %         hold on;
    %         plot(cr_test_sec(1)*[1 1],ylim,'k:','linewidth',2);
    %         plot(cr_test_sec(2)*[1 1],ylim,'k:','linewidth',2);
    %         plot(cr_test_sec,cr_output_dBFS,'ko','linewidth',2);
    %         yl=ylim;
    %         y = min([yl(2)-0.05*diff(yl) max([cr_output_dBFS+0.05*diff(yl)])]);
    %         text(mean(cr_test_sec),y, ...
    %             ['CR = ' num2str(apparent_CR,2)], ...
    %             'VerticalAlignment','bottom','HorizontalAlignment','center');
    %     end
    %h=weaText(fname,2);set(h,'interpreter','none');set(h,'BackgroundColor','white');
    
    foo_amp_dB(:,end+1)=amp_dB;
end
pos=get(gcf,'position');
linkaxes(ax,'x');

%% summary figure
figure;set(gcf,'position',pos);
subplot(2,2,1);
plot(t_sec(1:dec_fac:end),foo_amp_dB(1:dec_fac:end,:),'linewidth',2);
if ~isempty(t_lim_sec);xlim(t_lim_sec);end;
ylim([-55 5]);dB_lim = ylim;
title('Compare Signal Amplitude');
h=legend({'To Teensy','From Teensy'});moveLegendToSide(h);
xlabel('Time (sec)');
ylabel('Amplitude (dBFS)');
xl=xlim;yl=ylim;
text(xl(2)+0.04*diff(xl),yl(1)+0.02*diff(yl), ...
    {['Comp Ratio = ' num2str(comp_ratio) ':1'];
    ['Comp Knee = ' num2str(thresh_dBFS) ' dBFS'];
    ['Attack = ' num2str(ar_msec(1)) ' ms'];
    ['Release = ' num2str(ar_msec(2)) ' ms']},...
    'VerticalAlignment','Bottom','HorizontalAlignment','Left');

subplot(2,2,3);
plot(foo_amp_dB(:,1),foo_amp_dB(:,2),'k-','linewidth',2);
xlabel('Input Amplitude (dBFS)');
ylabel('Output Amplitude (dBFS)');
xlim(dB_lim);ylim(xlim);
title('Effect of Compressor');
xl=xlim;yl=ylim;
text(xl(2)+0.04*diff(xl),yl(1)+0.02*diff(yl), ...
    {['Comp Ratio = ' num2str(comp_ratio) ':1'];
     ['Comp Knee = ' num2str(thresh_dBFS) ' dBFS'];
     ['Attack = ' num2str(ar_msec(1)) ' ms'];
     ['Release = ' num2str(ar_msec(2)) ' ms']},...
     'VerticalAlignment','Bottom','HorizontalAlignment','Left');
 hold on;
 plot(thresh_dBFS*[1 1],ylim,'k--','linewidth',2);
 text(thresh_dBFS,yl(2)-0.05*diff(yl),{'Thresh';[num2str(thresh_dBFS) 'dBFS']},...
     'VerticalAlignment','top','HorizontalAlignment','center',...
     'backgroundcolor','white');
 h = legend('Measured');moveLegendToSide(h);
 
 
