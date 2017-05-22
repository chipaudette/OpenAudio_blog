function [data,start_ind,Noverlap,window]=blockData2(indata,N,overlap,windowing)
%function [data,start_ind,Noverlap,window]=blockData2(indata,N,overlap,windowing)
%
%Note: Hanning window assumed by default.  Set windowing='no_windowing' to
%      have no windowing of data blocks.

% JLB 11/01/02 Modified to allow multi-channel inData.  
% JLB 11/01/02 Changed procedure to use reshape and avoid for loops whenever possible.  

if (nargin < 4)
  windowing=[];
end

% Work out indata dimensions
[nData,nChan]   = size(indata);
if nChan > nData    % For some reason, convention not upheld
    indata          = indata';
    [nData,nChan]   = size(indata);
end
if nChan > 1
    indata          = mean(indata')';
end

% Break into blocks
Noverlap    = floor(N*(1-overlap));
if (Noverlap==0);Noverlap=1;end;

%Commented WEA NOV 4 2002
%nCol        = floor(nData/Noverlap);
nCol        = floor((nData-N)/Noverlap)+1;


%Commented WEA NOV 4 2002
%idxMat      = [1:N]'*ones(1,nCol) + ones(N,1)*[0:nCol-1]*(Noverlap-1);
idxMat      = [1:N]'*ones(1,nCol) + ones(N,1)*[0:nCol-1]*(Noverlap);
data        = indata(idxMat);
len_indata = length(indata);
clear idxMat indata

% Apply window of choice
if ((strcmpi(windowing,'no_windowing')==1) | (strcmpi(windowing,'none')));
  window    = ones(N,1);
elseif isempty(windowing)
  try
      window    = hanning(N);
  catch
      window = chip_hanning(N);
  end
elseif (strcmpi(windowing,'chip_hanning')==1);
    window = chip_hanning(N);
else
  eval(['window = ' windowing '(N);']);
end
data        = data.*(window*ones(1,nCol));


% To be yanked VVVVVVVVV
start_ind = [1:Noverlap:(len_indata-N+1)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
function [window]=chip_hanning(N)
%Creates a hanning window of length N where first and last samples are
%zero

if (0)
    N=N+2;  %make sure first and last samples are non-zero;
    x=[0:1/(N-1):1]';x=x(2:end-1);
else
   x=[0:1/(N-1):1]';
end
window = 0.5*sin(2*pi*x - pi/2)+0.5;
