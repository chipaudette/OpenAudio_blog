%script: setFigureTallestWidest
%purpose: increases the size of the figure on the screen
function setFigureTallestWidest

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
    
    mid_x_point = pos(1)+pos(3)/2;
    new_width = 3.25*pos(3);
    gutter = 10;
    max_allowed_width = (screen(3)-2*gutter);
    if (new_width > max_allowed_width)
        new_width = max_allowed_width;
    end
    set(gcf,'position',[(mid_x_point - new_width/2) ypos new_width height]);
end
%setFigSizeLandscape;
if (1)
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'PaperPosition',[1.25 1.25 8.5 6]);
else
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPosition',[1 1 6.5 9]);
end
