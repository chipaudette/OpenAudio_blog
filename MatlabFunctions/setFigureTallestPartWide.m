%script: setFigureTallestPartWide
%purpose: increases the size of the figure on the screen
function setFigureTallestPartWide

pos=get(gcf,'position');
if (pos(4) < 500)
    ypos = pos(2)-1.4*pos(4);
    height = (1+1.4)*pos(4);
    
    screen = get(0,'ScreenSize');
    gutter = 35+3;
    max_allowed_height = 0.9*(screen(4) - gutter);
    if (height > max_allowed_height)
        height = max_allowed_height;
        ypos = gutter+0.01*max_allowed_height;
    end
    
    old_width = pos(3);
    new_width = 1.5*old_width;
    set(gcf,'position',[pos(1)-(new_width - old_width)/2 ypos new_width height]);
end
%setFigSizeLandscape;
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperPosition',[1.25 1.25 8.5 6])