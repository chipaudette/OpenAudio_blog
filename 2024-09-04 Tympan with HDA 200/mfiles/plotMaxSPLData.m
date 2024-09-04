
% copy-paste data from Excel
data = [
125	109.8	79.3
250	114.0	96.0
500	115.7	104.7
750	113.7	107.7
1000	113.2	107.7
1500	108.4	102.9
2000	108.6	104.1
3000	107.9	105.4
4000	107.0	97.5
5000	108.8	94.8
6000	109.1	92.1
8000	108.1	90.6
9000	106.0	87.0
10000	104.4	82.4
11200	103.5	80.5
12500	103.7	76.2
14000	102.7	67.7
16000	104.0	48.0
];

%parse out the data
freq_Hz = data(:,1);
SPL_dB = data(:,2);
HL_dB = data(:,3);

%plot the SPL data
figure;
semilogx(freq_Hz,SPL_dB,'o-','linewidth',2);
xlim([125, 16000])
ylim([50, 120]+10)
set(gca,'xtick',[125,250,500,1000,2000,4000,8000,16000])
set(gca,'xticklabels',{'125','250','500','1K','2K','4K','8K','16K'})
title('Tympan Driving HDA 200 Headset')
ylabel({'Max dB SPL';'meeting set distortion thresholds'})
xlabel('Frequency (Hz)')
set(gca, 'XMinorTick', 0)

%plot the HL data
figure;
semilogx(freq_Hz,HL_dB,'o-','linewidth',2);
xlim([125, 16000])
ylim([40, 120])
set(gca,'xtick',[125, 250,500,1000,2000,4000,8000,16000])
set(gca,'xticklabels',{'125','250','500','1K','2K','4K','8K','16K'})
title('Tympan Driving HDA 200 Headset')
ylabel({'Max dB HL';'meeting set distortion thresholds'})
xlabel('Frequency (Hz)')
set(gca, 'XMinorTick', 0)

