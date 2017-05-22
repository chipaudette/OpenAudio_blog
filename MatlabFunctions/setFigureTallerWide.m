%script: setFigureTallerWide
%purpose: increases the size of the figure on the screen
function setFigureTallerWide

pos=get(gcf,'position');
if (pos(4) < 500)
    set(gcf,'position',[pos(1)-pos(3)/2 pos(2)-1*pos(4) 2*pos(3) (1+1)*pos(4)]);
end
%setFigSizeLandscape;
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperPosition',[1.25 1.25 8.5 6])