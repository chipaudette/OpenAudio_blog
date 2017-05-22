%script: setFigureTallWide
%purpose: increases the size of the figure on the screen

pos=get(gcf,'position');
if (pos(3) < 700)
    set(gcf,'position',[pos(1)-pos(3)/2 pos(2) 2*pos(3) pos(4)]);
end
%setFigSizeLandscape;
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperPosition',[1.25 1.25 8.5 6])