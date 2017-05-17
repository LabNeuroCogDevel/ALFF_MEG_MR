mrts=readMR();
MRfft=spectrumMR(mrts,'fft');
% TODO: reindex mat to match MEG
% want: roi  x freq x subj
% have: freq x roi x subj
%MRwelch=spectrumMR(mrts,'welch');

meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat')
MEGwelch=spectrumMEG(meg.MEGTimeSeries);

for roi=1:7
  corr
end



