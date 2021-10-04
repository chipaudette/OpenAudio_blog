%% Plots for Self-Noise of Tynpan Rev-D1 vs D2

%Plot window positions for blog
figurePosBlog = [1927 469 1103 467];
figurePosW2SublotBlog = [1927 69 1103 867];
subplot1PosBlog = [0.1300 0.6400 0.7750 0.3012];
subplot2PosBlog = [0.1300 0.0882 0.7750 0.3612];

%Add plot folder
plotDir = [homeDir '\Plots\SelfNoise_Tympan_RevD1vsD2'];
if( ~exist(plotDir, 'dir' ) )
    mkdir(plotDir);
end


%% ---------------------------------------------------------
%% Plot Sensitivity (dBFS/Pa) over Octave bands for all input gains
figId = figure(200); clf; 
colorOrder = jet(10);

%Cases and trials to plot
clear plotInfo
plotInfo.cases  = [3 4]; %RevD1-PCB, RevD2-PCB

%Create labels for plot legend showing input gain
caseIdx = 3;
clear testMicInputGainLabels     
testMicInputGainLabels{1} = [num2str(testCase(caseIdx).trial(1).info.testMicInputGain_dB) 'dB'];
testMicInputGainLabelsAll = char( testMicInputGainLabels(1) );
for trialIdx = 2:length(testCase(caseIdx).trial)
    testMicInputGainLabels{trialIdx} = [num2str(testCase(caseIdx).trial(trialIdx).info.testMicInputGain_dB) 'dB'];
    testMicInputGainLabelsAll = [testMicInputGainLabelsAll, ', ' char( testMicInputGainLabels(trialIdx) )];
end

%Calculate Increased Gain from Rev-D1 to rev-D2
clear gain_dB
subplotHandle(1) = subplot(3,1,1); hold on
for trialIdx = 1:length(testCase(caseIdx).trial)
    %Skip over empty files
    if( ~isempty(testCase(caseIdx).trial(trialIdx).info) )
        gain_dB(:,trialIdx) = testCase(4).trial(trialIdx).testMicSens_dBFS_Pa - ...
            testCase(3).trial(trialIdx).testMicSens_dBFS_Pa;
    end
end
errorbar(testCase(4).trial(trialIdx).testMicOctaveFreq_Hz/1000,...
    mean(gain_dB,2), 2.*std(gain_dB,0, 2), '.', 'color', [.7 .7 .7], 'markersize', 10);
plot(testCase(4).trial(trialIdx).testMicOctaveFreq_Hz/1000,...
    mean(gain_dB,2), 'k-', 'linewidth', 1.25 );

%Format
set(gca, 'fontsize', 14');
title({'Increased Gain of Tympan PCB Mic:' 'Rev-D2 w/ preamp vs. Rev-D1 w/o preamp'}, 'fontsize', 16);
xLabelHandle(1) = xlabel('Freq(kHz)','Units', 'data', 'fontsize', 14);
xlabelNames = [testCase(4).trial(trialIdx).testMicOctaveFreq_Hz(1:end-1)/1000 16];
set(gca, 'xtick', xlabelNames);
xticklabels(gca, xlabelNames);
set(gca, 'XScale', 'log')
ylabel('Gain (db)', 'fontsize', 14);
xlim([.1 20]);
ylim([10 18]);
text(.125, 15.5, ['2*STD across Tympan Input Gain of [ ' testMicInputGainLabelsAll ' ]'] ); 
grid on

%Plot Sensitivity (dBFS/Pa) 
linIdx = 1;
for caseIdx = plotInfo(1).cases
    linIdx = linIdx + 1;
    subplotHandle(linIdx) = subplot(3,1,linIdx); hold on;
    for trialIdx = 1:length(testCase(caseIdx).trial)
        %Skip over empty files
        if( ~isempty(testCase(caseIdx).trial(trialIdx).info) )           
            plot(testCase(caseIdx).trial(trialIdx).calMicOctaveFreq_Hz/1000,...
                testCase(caseIdx).trial(trialIdx).testMicSens_dBFS_Pa ,...
                '-','color', colorOrder(trialIdx, :), 'markersize', 10);
        end
    end
    
    set(gca,'fontsize', 14);
    text(testCase(4).trial(trialIdx).calMicOctaveFreq_Hz(1)/1000, 14, ...
        ['Sensitivity of ' testCase(caseIdx).info.testCaseName], ...
        'fontsize', 16, 'FontWeight', 'bold');
    %legend( 'testMic Input Gain: ' char(testCase(caseIdx).trial( validTrialIdx(subplotIdx) ).info.trialName)]} );
    xLabelHandle(1) = xlabel('Freq(kHz)');
    ylabel('Sensitivity (dBFS/Pa)');
    legendHandle = legend(testMicInputGainLabels, 'location', 'NorthEastOutside');
    title(legendHandle, 'testMic Input Gain');
    set(gca, 'xtick', testCase(4).trial(trialIdx).calMicOctaveFreq_Hz(1:end)/1000);
    xticklabels(gca, testCase(4).trial(trialIdx).calMicOctaveFreq_Hz(1:end)/1000);
    set(gca, 'XScale', 'log')
    xlim([.1 20]);
    ylim([-40 20])
    grid on
end

%Resize Suplot#1 to match others
subplot(3,1,1);
subplotHandle(1).Position(3) = subplotHandle(2).Position(3);

%Save Plots
saveas(figureIdx,[plotDir '\Sensitivity of PCB Mics_RevD1vsD2']);
print(figureIdx, [plotDir '\Sensitivity of PCB Mics_RevD1vsD2'], '-dpng', '-r300');
print(figureIdx, [plotDir '\Sensitivity of PCB Mics_RevD1vsD2_web'], '-dpng', '-r72');


%% -----------------------------------------------------------------------
%% Plot Sensitivity 
figId = figure(500); clf;

%Set cases and trials to plot
clear plotInfo
plotInfo.cases  = [3 4]; %RevD1-PCB, RevD2-PCB
plotInfo(3).trials = 7;  %RevD1-PCB @ 15dB input gain
plotInfo(4).trials = 1;  %RevD2-PCB @ 0dB input gain

%Set Colors
clear colorOrder
colorOrder(3,:) = [204 51 0]/255;
colorOrder(4,:) = [204 0 204]/255;

%Plot Raw Output
clear subplotId
subplotId(1) = subplot(2,1,1); hold on

for caseIdx = plotInfo(1).cases 
    for trialIdx =  plotInfo(caseIdx).trials
        plot(testCase(caseIdx).trial(trialIdx).testMicOctaveFreq_Hz/1000,...
            testCase(caseIdx).trial(trialIdx).testMicPressureRms_dBFS, '-o', 'color',...
            colorOrder(caseIdx,:), 'linewidth', 4, 'MarkerSize', 12);
    end
end

%Format Plot
set(gca, 'fontsize', 20);
title('Raw Mic Response to Generated White Noise', 'fontsize', 22);
xlabel('Octave-Band Frequency (kHz)');
xlabelNames = [testCase(4).trial(trialIdx).testMicOctaveFreq_Hz(1:end-1)/1000 16];
set(gca, 'xtick', xlabelNames);
xticklabels(gca, xlabelNames);
set(gca, 'XScale', 'log');
ylabel({'Raw Recorded Level' '(dB; Ref: full-scale output)'});
xlim([.1 20]);
ylim([-70 -30]);
grid on
legend('Tympan D1 + PCB Mic (15dB Input Gain)', 'Tympan D2 + PCB Mic (0dB Input Gain)', 'Location', 'NorthWest'); 

%Plot Sensitivity
subplotId(2) = subplot(2,1,2); hold on
for caseIdx = plotInfo(1).cases 
    for trialIdx =  plotInfo(caseIdx).trials
        
        plot(testCase(caseIdx).trial(trialIdx).testMicOctaveFreq_Hz/1000,...
            testCase(caseIdx).trial(trialIdx).testMicSens_dBFS_Pa, '-o', 'color',...
            colorOrder(caseIdx,:), 'linewidth', 4, 'MarkerSize', 12);
    end
end

%Format Plot
title('Microphone Sensitivity', 'fontsize', 22);
set(gca, 'fontsize', 20);
xlabel('Octave-Band Frequency (kHz)');
set(gca, 'xtick', xlabelNames);
xticklabels(gca, xlabelNames);
set(gca, 'XScale', 'log');
ylabel({'Sensitivity (dB SPL)' '(per full-scale output)'});
xlim([.1 20]);
ylim([-25 -5]);
legend('Tympan D1 + PCB Mic (15dB Input Gain)', 'Tympan D2 + PCB Mic (0dB Input Gain)', 'Location', 'NorthWest'); 
grid on

figId.Position = figurePosW2SublotBlog;
subplotId(1).Position = subplot1PosBlog;
subplotId(2).Position = subplot2PosBlog;
saveas(figId,[plotDir '\Calibration_ResponseToWhiteNoise']);
print(figId, [plotDir '\Calibration_ResponseToWhiteNoise'], '-dpng', '-r300');
print(figId, [plotDir '\Calibration_ResponseToWhiteNoise_web'], '-dpng', '-r72');


%% -----------------------------------------------------------------------
%% Plot Self-Noise - Raw Mic Response
figId = figure(600); clf; hold on

%Set cases and trials to plot
clear plotInfo
plotInfo.cases  = [1 2]; %RevD1-PCB, RevD2-PCB
plotInfo(1).trials = 7;  %RevD1-PCB @ 15dB input gain
plotInfo(2).trials = 1;  %RevD2-PCB @ 0dB input gain

%Set Colors
clear colorOrder
colorOrder(1,:) = [204 51 0]/255;
colorOrder(2,:) = [204 0 204]/255;


for caseIdx = plotInfo(1).cases 
    for trialIdx =  plotInfo(caseIdx).trials
        plot(testCase(caseIdx).trial(trialIdx).testMicOctaveFreq_Hz/1000,...
            testCase(caseIdx).trial(trialIdx).testMicPressureRms_dBFS, '-o', 'color',...
            colorOrder(caseIdx,:), 'linewidth', 4, 'MarkerSize', 12);
    end
end

%Format Plot
set(gca, 'fontsize', 20);
title('Raw Mic Response in Quiet Sound Room', 'fontsize', 22);
xlabel('Octave-Band Frequency (kHz)');
set(gca, 'xtick', xlabelNames);
xticklabels(gca, xlabelNames);
set(gca, 'XScale', 'log');
ylabel({'Raw Recorded Level(dB)' '(Ref:fullscale)'});
xlim([.1 20]);
ylim([-110 -40]);
legend('Tympan D1 + PCB Mics (15dB Input Gain)', 'Tympan D2 + PCB Mics (0dB Input Gain)'); 
grid on

figId.Position = figurePosBlog;
saveas(figId,[plotDir '\Self-Noise_Raw Output']);
print(figId, [plotDir '\Self-Noise_Raw Output'], '-dpng', '-r300');
print(figId, [plotDir '\Self-Noise_Raw Output_web'], '-dpng', '-r72');

