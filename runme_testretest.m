% Run data through test/retest

trmrts = readTestRetest();
ids=cellfun(@str2double,{trmrts.id});
checks = [ ...
    mod(length(trmrts),2) == 0           ... even number of things
    all([trmrts(1:2:end).scanno]==1)     ... odds are  scanno 1
    all([trmrts(2:2:end).scanno]==2)     ... evens are scanno 2
    ~any( ids(1:2:end) - ids(2:2:end) )  ... ids are paired
    ~any([trmrts(1:2:end).age] - [trmrts(2:2:end).age] ) ... ages are paired
];
if ~all(checks); stop('bad test retest data!'); end

[trMRfft,mr_freq]=spectrumMR(trmrts,'fft');

% how to group frequences
calcbands=@(x) [x(1:(end-1)); x(2:end) ]';
mrbands=calcbands([ .001 .004 .007 10.^[-2:.25:-.25] ]);

% calcluate all fluctuations
flux1  = calc_allflux(trMRfft(:,:,1:2:end) ,mr_freq,mrbands,{});
flux2  = calc_allflux(trMRfft(:,:,2:2:end),mr_freq,mrbands,{}) ;

% calc correlations between flux
computelist={'falf','alf','hpfalf','alf_all','falf_all','hpfalf_all'};
tr_allcorrs = calc_corrs(flux1,flux2,computelist,computelist);

% 2d corr plot
roicorr = [ tr_allcorrs.alf.alf, tr_allcorrs.falf.falf, tr_allcorrs.hpfalf.hpfalf];
roicorlab= {'alff','falff','hpfalff'};
plot_2dcorr(roicorr,roicorlab);
title('test retest network by method')

% labels
mrbandlabels=cellfun(@(x) sprintf('%02.03f',x) ,num2cell(mean(mrbands,2)),'UniformOutput',0);
mrlabelidxs=1:length(mrbandlabels);

% plot lines
tr_linedata= {tr_allcorrs.alf.alf_all, tr_allcorrs.falf.falf_all, tr_allcorrs.hpfalf.hpfalf_all};
tr_line_legend={'alff','falff','hpfalff'};
plot_roi_band(tr_linedata,tr_line_legend,mrbands)
% plotmat
plotdata_mats = { tr_allcorrs.hpfalf_all.hpfalf_all, tr_allcorrs.alf_all.alf_all,tr_allcorrs.falf_all.falf_all};
plotlabel_mats = { 'hpalffbands'                    ,           'alffbands'      ,        'falffbands'           };
plot_band_band_roi( plotdata_mats, plotlabel_mats, mrlabelidxs-1,mrbandlabels, mrlabelidxs,mrbandlabels );

plotdata_mats = {  tr_allcorrs.alf_all.alf_all};
plotlabel_mats = { 'alfbands'  };
plot_band_band_roi( plotdata_mats, plotlabel_mats, mrlabelidxs-1,mrbandlabels, mrlabelidxs,mrbandlabels );
