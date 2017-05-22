%script: setFigureTallWide
%purpose: increases the size of the figure on the screen
function setFigureTallWide

pos=get(gcf,'position');
if (pos(4) < 500)
    old_width = pos(3);
    new_width = 3.25*old_width;
    
    screen = get(0,'ScreenSize');
    gutter = 10;
    max_allowed_width = (screen(3)-2*gutter);
    if (new_width > max_allowed_width)
        new_width = max_allowed_width;
    end
    
    set(gcf,'position',[pos(1)-(new_width - old_width)/2 pos(2)-2/3*pos(4) new_width (1+2/3)*pos(4)]);
end
%setFigSizeLandscape;
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperPosition',[1.25 1.25 8.5 6])