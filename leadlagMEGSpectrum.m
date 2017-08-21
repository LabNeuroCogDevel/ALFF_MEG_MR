function [ d ] = leadlagMEGSpectrum(MEGTimeSeries,leadbyidx, lagbyidx)
%leadlagMEG create versions of data with lead and lag in increments
%   output is structu with fields
%    lead,lag
%       fft [7 x 751 x 62],freq [751], idx [size({lead,lag}byidx)]

% timeseries input cell {id,[timepoint x roi]} from
%  meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat');
%  meg.MEGTimeSeries
%
% lead and lag indexs are where to put cuts
%   N.B. lead adds 1 to value given so 0 is valid
%        so there is symatry with lag (0 means subtract none, 0 means start
%        at first)
%
% output emulates
%  [MEGfft_org, meg_freq]=spectrumMEG(meg.MEGTimeSeries,6); % 10sec bins; NB. roi x psd x subj


    d.lead=[];
    d.lag=[];
    
    % what to use for padding in lead and lag values
    padwith=0;

    %% [ 0, 1:n-1 ]
    for i=1:length(lagbyidx)
     startat=lagbyidx(i);
     trimmeddata=MEGTimeSeries;
     trimmeddata(:,2)=cellfun(@(x) lagit(x,startat,padwith), MEGTimeSeries(:,2),'UniformOutput',0);
     d.lag(i).idx=startat;
     [d.lag(i).fft,d.lag(i).freq]=spectrumMEG(trimmeddata,6); 
    end


    %% lead [2:n, 0 ]
    for i=1:length(leadbyidx)
     minusidx=leadbyidx(i) +1; % because we are not zero based
     trimmeddata=MEGTimeSeries;
     trimmeddata(:,2)=cellfun(@(x) leadit(x,minusidx,padwith), MEGTimeSeries(:,2),'UniformOutput',0);
     
     d.lead(i).idx=minusidx;
     [d.lead(i).fft,d.lead(i).freq]=spectrumMEG(trimmeddata,6); 
    end



end

%% helper functions
% lag ts (1:10 --> [ 0 1:0 ] )
function megcell = lagit(ts,idx,padval)
    pad=mkpadding(idx,size(ts,2),padval);
    megcell = [pad; ts(1:(end-idx),:)];
end

% lead ts (1:10 --> [2:10 0] )
function megcell = leadit(ts,idx,padval)
    pad=mkpadding(idx,size(ts,2),padval);
    megcell = [ts(idx:end,:); pad ];
end

% make an empty array or a n x l array of padded values
% to prepend/append to lag/lead ts
function pad=mkpadding(n,l,padval)
  pad=[];
  if ~isempty(padval)
      pad=ones(n,l) .* padval;

  end
end
