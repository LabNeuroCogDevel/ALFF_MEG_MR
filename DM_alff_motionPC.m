%% read data
mrts=readMR('/Volumes/Zeus/ALFF/full/subjs/*/fALFF/DM_Y7_3mm_roistats.txt');


%% what bands
calcbands=@(x) [x(1:(end-1)); x(2:end) ]';
%bands=10.^[-2:.1:2]; % started with .4 -- but samples too high to grab the low end (e.g. find(meg_f > .012 & meg_f < .0132) is empty)
%bands=[bands(1:(end-1)); bands(2:end) ]';
meg_bands=calcbands(10.^[-2:.1:2]);


mrbands=calcbands([ .001 .004 .007 10.^[-2:.25:-.25] ]);
