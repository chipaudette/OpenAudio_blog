function win = hanning(N)
%function win = hanning(N)
%Created: WEA Jan 27, 2014

win = (1 - cos(2*pi*[1:N]/(N+1)))/2;
win = win(:);
