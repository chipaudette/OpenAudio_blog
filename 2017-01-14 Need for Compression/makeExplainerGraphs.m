
in_dBFS = [-80:0];
linear_out_dBFS = in_dBFS;

%compute compressed output
comp_out_dBFS = in_dBFS;
thresh_dBFS = -30;
comp_ratio = 3;
excess_dB = in_dBFS - thresh_dBFS;
inds = find(excess_dB > 0);
comp_out_dBFS(inds) = thresh_dBFS + excess_dB(inds)/comp_ratio;

gain_dB = comp_out_dBFS - linear_out_dBFS;

% graphs
figure;setFigureTallWide;
%pos=get(gcf,'position');set(gcf,'position',[pos(1)-100 pos(2) 505 325]);
%figure;setFigureTall;pos=get(gcf,'position'); set(gcf,'position',[pos(1:2) 505 0.75*pos(4)]);

subplot(2,2,1);
plot(in_dBFS,linear_out_dBFS,'k:','linewidth',2);
hold on;
plot(in_dBFS,comp_out_dBFS,'linewidth',3);
hold off
xlabel('Input Level (dB re: Full-Scale)');
ylabel('Output Level (dB re: Full-Scale)');
title('Notional Dynamic-Range Compressor');
legend({'No Compressor',[num2str(comp_ratio) ':1 Compressor']}, ...
    'location','northwest');
weaText(['Threshold (Knee) at ' num2str(thresh_dBFS) ' dB FS'],4);

subplot(2,2,2);
figure;pos=get(gcf,'position');set(gcf,'position',[pos(1)+100 pos(2) 505 325]);
plot(in_dBFS,zeros(size(in_dBFS)),'k:','linewidth',2);
hold on;
plot(in_dBFS,gain_dB,'linewidth',3);
hold off
ylim([-30 20]);
xlabel('Input Level (dB re: Full-Scale)');
ylabel('Compressor Gain (dB)');
title('Notional Dynamic-Range Compressor');
legend({'No Compressor',[num2str(comp_ratio) ':1 Compressor']}, ...
    'location','northwest');
weaText(['Threshold (Knee) at ' num2str(thresh_dBFS) ' dB FS'],4);


%% make SPL graph
SPL_dB=[];  names={};
%http://hearingsense.com.au/causes-of-hearing-loss/
SPL_dB(end+1) = 30;  names{end+1}='Whisper';
SPL_dB(end+1) = 60;  names{end+1}='Conversation';
SPL_dB(end+1) = 75;  names{end+1}='Loud Restaurant';
SPL_dB(end+1) = 90;  names{end+1}='Lawn Mower';
%SPL_dB(end+1) = 100; names{end+1}='Hair Dryer';
SPL_dB(end+1) = 110; names{end+1}='Chain Saw';
vals_SPL_dB = [-30:140];

figure;setFigureTallWide;
for I=1:2
    subplot(2,2,I);
    x = SPL_dB; y = SPL_dB;
    plot(vals_SPL_dB,vals_SPL_dB,'k:',x,y,'ko','linewidth',2,'markerfacecolor','white');
    xlabel('Sound Pressure Level (dBA)');
    ylabel('Sound Level in Ear (dBA)');
    if I==1
        title('Normal Hearing');
    else
        title('40dB Hearing Loss');
    end
    xlim([0 145]);dB_lim = xlim; ylim(dB_lim);
end

subplot(2,2,3);
gain_dB = 30;
y_gain = y+gain_dB;
vals_gain = vals_SPL_dB+gain_dB;
plot(x,y_gain,'ko-','linewidth',2);
plot(vals_SPL_dB,vals_gain,'k:',x,y_gain,'ko','linewidth',2,'markerfacecolor','white');
xlabel('Sound Pressure Level (dBA)');
ylabel('Sound Level in Ear (dBA)');
title(['Linear Hearing Aid']);
xlim(dB_lim);ylim(xlim);
weaText([num2str(gain_dB) 'dB Gain'],4);

subplot(2,2,4)
comp_ratio=2; thresh_dB = 70;
y_comp = y_gain;  vals_comp = vals_gain;
I=find(y_comp > thresh_dB);y_comp(I) = thresh_dB + (y_comp(I)-thresh_dB)/comp_ratio;
I=find(vals_comp > thresh_dB);vals_comp(I) = thresh_dB + (vals_comp(I)-thresh_dB)/comp_ratio;
plot(vals_SPL_dB,vals_comp,'k:',x,y_comp,'ko','linewidth',2,'markerfacecolor','white');
xlabel('Sound Pressure Level (dBA)');
ylabel('Sound Level at Ear (dBA)');
title(['Compression Hearing Aid']);
xlim(dB_lim);ylim(xlim);
weaText({[num2str(gain_dB) 'dB Gain'];
         [num2str(comp_ratio) ':1 Comp Ratio'];
         ['Threshold at ' num2str(thresh_dB) 'dBA']},4);

for Iplot=1:4
    subplot(2,2,Iplot);
    xl=xlim;yl=ylim;
    for I=1:length(names);
        switch Iplot
            case 1
                y_plot = y + 0.02*diff(yl);va_txt = 'Bottom';ha_txt='Right';
            case 2
                y_plot = y + 0.02*diff(yl);va_txt = 'Bottom';ha_txt='Right';
            case 3                
                y_plot = y_gain - 0.02*diff(yl);va_txt = 'Top';ha_txt ='Left';
            case 4
                y_plot = y_comp + 0.02*diff(yl);va_txt = 'Bottom';ha_txt ='Right';
        end
        text(x(I),y_plot(I),names{I},'VerticalAlignment',va_txt,...
            'HorizontalAlignment',ha_txt,'FontWeight','bold');
    end
end
    
