function h=moveLegendToSide(h,nudge)
%function hLegend=moveLegendToSide(hLegend)

if (nargin < 2)
    nudge = 0.02;
end

pos=get(h,'position');
set(h,'position',[pos(1)+pos(3)+nudge pos(2) pos(3) pos(4)]);

