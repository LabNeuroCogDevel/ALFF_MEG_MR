% SM WF 20170612

function out = calc_alff(d,f,fun,alffreq)
%% MEG_FALFF -- calculate FALFF for meg data at 7 predefined freq bands
% frac amp low freq flux

  % MEG
  if isempty(alffreq)
    alffreq = ...
    [ .01 .1; ... ultra slow 
       .1  1; ... slow
        1  3; ... delta
        3  8; ... theta
        8 14; ... alpha
       14 30; ... beta
       30 100;... gama
    ];
  end
  nfreq = size(alffreq,1);
  out = zeros(1,nfreq);

  totalpower=fun(d);

  for fi = 1:nfreq
    low  = alffreq(fi,1);
    high = alffreq(fi,2);
    meg_falf_idx = f > low & f <= high;
    %range(find(meg_falf_idx))
    out(fi) = nansum(d(meg_falf_idx))/totalpower;
  end

end
