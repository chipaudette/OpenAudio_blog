function setFigureSpaceNarrow;
%function setFigureSpaceNarrow;

pos=get(gcf,'DefaultAxesPosition');
set(gcf,'DefaultAxesPosition',[pos(1:2) 0.7 pos(4)]);
