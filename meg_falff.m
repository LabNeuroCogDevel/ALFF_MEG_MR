% SM WF 20170612

function meg_falf_out = meg_falff(megp,meg_f,fun)
%% MEG_FALFF -- calculate FALFF for meg data at 7 predefined freq bands
% frac amp low freq flux

  % MEG
  megfalffreq = ...
  [ .01 .1; ... ultra slow 
     .1  1; ... slow
      1  3; ... delta
      3  8; ... theta
      8 14; ... alpha
     14 30; ... beta
     30 100;... gama
  ];
  nmegfreq = size(megfalffreq,1);
  meg_falf_out = zeros(1,nmegfreq);

  meg_totalpower=fun(megp);

  for fi = 1:nmegfreq
    low  = megfalffreq(fi,1);
    high = megfalffreq(fi,2);
    meg_falf_idx = meg_f > low & meg_f < high;
    %range(find(meg_falf_idx))
    meg_falf_out(fi) = nansum(megp(meg_falf_idx))/meg_totalpower;
  end

end
