%script: setFigureTall
%purpose: increases the size of the figure on the screen
function []=setFigureTall;

pos=get(gcf,'position');
if (pos(4) < 500)
    set(gcf,'position',[pos(1) pos(2)-2/3*pos(4) pos(3) (1+2/3)*pos(4)]);
end

%setFigSize;
set(gcf,'PaperPosition',[1.25 1.5 6 8]);
