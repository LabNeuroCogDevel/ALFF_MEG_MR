mrts=readMR();
MRfft=spectrumMR(mrts,'fft');
MRwelch=spectrumMR(mrts,'welch');

meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat')