%%% MMY4 mr vs meg

%% read in data
mrts=readMR();
%mrts=readMR('/Volumes/Zeus/ALFF/full/subjs/*/fALFF/DM_Y7_3mm_roistats.txt');
%mrts=readMR('/Volumes/Zeus/ALFF/full/subjs/*/fALFF/simpmot_Y7_3mm_roistats.txt');


[MRfft_org,mr_freq]=spectrumMR(mrts,'fft');
% roi x psd x subj
meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat');
[MEGfft_org, meg_freq]=spectrumMEG(meg.MEGTimeSeries);

megid = [ meg.MEGTimeSeries{:,1} ];
mrid  = [cellfun( @(x) str2double(x), {mrts.id}) ];
[mrdata_good,megdata_good ] = matchMRMEG(MRfft_org,MEGfft_org.mrid,megid);



%% create bands

calcbands=@(x) [x(1:(end-1)); x(2:end) ]';

meg_bands=calcbands(10.^[-2:.1:2]);
mrbands  =calcbands([ .001 .004 .007 10.^[-2:.25:-.25] ]);

%% calc alff and run correlations

mrflux   = calc_allflux(mrdata_good ,mr_freq,mrbands,{});
megflux  = calc_allflux(megdata_good,meg_freq,meg_bands,{'alf_all'}); %,'falf_all'}); -- dont need falf_all
allcorrs = calc_corrs(mrflux,megflux,{},{'alf_all'});




%% plot
%roilabels={'Visual','Somatomotor','Dorsal Attention','Ventral Attention', 'Limbic','Frontoparietal','Default'};

% line plot
mr_line_legend={'falff /(s+g+f)'     ,'alff g/1'          ,'hpfalff g/(g+f)'      ,'freqrat (s+g)/(g+f)'   };
plotdata      ={allcorrs.falf.alf_all,allcorrs.alf.alf_all,allcorrs.hpfalf.alf_all,allcorrs.freqrat.alf_all};
plot_roi_band(plotdata,mr_line_legend,meg_bands)

% labels
bandlabels=cellfun(@(x) sprintf('%02.02f',x) ,num2cell(mean(meg_bands,2)),'UniformOutput',0);
labelintv=2;
labelidxs=0:labelintv:length(bandlabels)-1;

mrbandlabels=cellfun(@(x) sprintf('%02.03f',x) ,num2cell(mean(mrbands,2)),'UniformOutput',0);
mrlabelidxs=1:length(mrbandlabels);

% a bunch of mat plots
plotdata_mats = { allcorrs.hpfalf_all.alf_all, allcorrs.alf_all.alf_all,allcorrs.falf_all.alf_all};
plotlabel_mats = { 'hpalf vs meg alf', 'meg vs mr alf','mr falf vs meg alf'};
plot_band_band_roi( plotdata_mats, plotlabel_mats, labelidxs,bandlabels, mrlabelidxs,mrbandlabels );


% ==NOTES==
% validate: -- before removing bad as above
%  ~any( allcorrs.alf.alf_all(:) - corr_alf(:) )
%  ~any(any( squeeze(mean(megflux.alf_all,2)) - squeeze(mean(megalf,2)) )) 
%  ~any(any( squeeze(mean(mrflux.alf,2))      - squeeze(mean(mralf(good_subjs_idx,:),2)) ))
%
% remove missing -- now done first
%   good_subjs_idx = ~isnan(mean(squeeze(mean(megflux.falf_all,2)),2)) & ~isnan(mean(mrflux.falf,2));
%   for f=fieldnames(mrflux);  mrflux.(f{1})  =  mrflux.(f{1})(good_subjs_idx,:,:); end
%   for f=fieldnames(megflux); megflux.(f{1}) = megflux.(f{1})(good_subjs_idx,:,:); end


