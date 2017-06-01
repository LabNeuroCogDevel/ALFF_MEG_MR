mrts=readMR();
meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat');

MRfft=spectrumMR(mrts,'fft');
MRwelch=spectrumMR(mrts,'welch');


save('timeseries.mat','meg','mrts')
