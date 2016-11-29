
%setup: Teensy 3.2 with Audio Board (Rev B, my first one from 2015).
%programmed to play sine wave at 1kHz at amplitude of 0.95.
%headphone output is set by potentiometer in 0.05 steps.
%I used fluike 115 multimeter to measure the RMS voltage of the output
%USB was set to serial so that I could observe the headphone setting.

data = [0 2.3
    0.05   3.5
    0.1 4.5
    0.15    5.9
    0.2 8.1
    0.25    11.2
    0.3 16.4
    0.35    22.8
    0.4 34.0
    0.45    52.6
    0.5 76.6
    0.55    120.9
    0.6 180.2
    0.65    273.5
    0.7 397.5
    0.75    608.5
    0.8 859
    0.85    1190
    0.9 1297
    0.95    1370
    1.0  1402];  %[value, mVrms]

headphone_vol = data(:,1);
headphone_Vrms = data(:,2)/1000;
headphone_dBV = 20*log10(headphone_Vrms);

figure;setFigureTall
subplot(2,1,1);
plot(headphone_vol,headphone_dBV,'o-','linewidth',2);
xlabel('Headphone Volume Command');
ylabel({'Measured Output Voltage (dBV)';'10*log10(V_{rms}^2)'});
xlim([0 1]);
title({'Effect of Headphone Volume Command';'Teensy Audio Board (SGTL5000)'});
weaText('Sine Wave at 0.95 Amplitude',4)
    
% fit line to the linear portion
I=find((headphone_vol >= 0.4)  & (headphone_vol <= 0.75));
p = polyfit(headphone_vol(I),headphone_dBV(I),1);
plot_hp_vol = headphone_vol;
plot_hp_dBV = polyval(p,plot_hp_vol);
hold on;
plot(plot_hp_vol, plot_hp_dBV,'k--','linewidth',2);
hold off
weaText({['Slope = ' num2str(p(1),4) ' dBV/value'];['Offset = ' num2str(p(2),4) ' dBV']},2);

%%%%%%%%% also show line-in level
data = [0 3.12
        1 2.63
        2 2.22
        3 1.87
        4 1.58
        5 1.33
        6 1.11
        7 0.94
        8 0.79
        9 0.67
        10 0.56
        11 0.48
        12 0.40
        13 0.34
        14 0.29
        15 0.24];  %value, Vpp
lineIn_val = data(:,1);
lineIn_Vpp = data(:,2);
lineIn_dBV = 20*log10(lineIn_Vpp/2/sqrt(2));

subplot(2,1,2);
plot(lineIn_val,lineIn_dBV,'o-','linewidth',2);
xlabel('Line-In Full-Scale Command');
ylabel({'Input Full-Scale (dBV)';'10*log10(V_{rms}^2)'});
xlim([0 15]);
set(gca,'XTick',lineIn_val);
title({'Effect of Line-In Level Command';'Teensy Audio Board (SGTL5000)'});
weaText('From Docs for Teensy Audio Board',3);
    
% fit line to the linear portion
I=find((lineIn_val >= 4)  & (lineIn_val <= 13));
p = polyfit(lineIn_val(I),lineIn_dBV(I),1);
plot_val = lineIn_val;
plot_dBV = polyval(p,plot_val);
hold on;
plot(plot_val, plot_dBV,'k--','linewidth',2);
hold off
weaText({['Slope = ' num2str(p(1),4) ' dBV/value'];['Offset = ' num2str(p(2),4) ' dBV']},1);
