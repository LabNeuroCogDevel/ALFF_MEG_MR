%%% MMY4 mr vs meg

%% read in data
mrts=readMR();
%mrts=readMR('/Volumes/Zeus/ALFF/full/subjs/*/fALFF/DM_Y7_3mm_roistats.txt');


[MRfft_org,mr_freq]=spectrumMR(mrts,'fft');
% roi x psd x subj
meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat');
[MEGfft_org, meg_freq]=spectrumMEG(meg.MEGTimeSeries);


%% order by id, remove missing subject
megid = [ meg.MEGTimeSeries{:,1} ];
mrid  = [cellfun( @(x) str2num(x), {mrts.id}) ];

[megid_sort,megsubjidx] = sort(megid);
[mrid_sort,mrsubjidx]   = sort(mrid);

% remove missing meg from mr -- so both match 
missingmeg = setdiff(mrid_sort,megid_sort); % 11405
mrkeep     = mrid_sort~=missingmeg;       % not index 47 when sorted

MEGfft = MEGfft_org(:,:,megsubjidx);
MRfft  = MRfft_org (:,:,mrsubjidx(mrkeep) );
% make time by roi by subj
MEGfft_matchdim  = permute( MEGfft, [2,1,3] );


% this is what we want formated in the same way
mrdata= MRfft;
megdata=MEGfft_matchdim;

% but we data missing in MEG
badmeg = squeeze(all(all(megdata == 0)));
badmr  = squeeze(all(all(mrdata == 0)));
good_subjs_idx = ~badmeg & ~badmr;

% finally data taht is good
mrdata_good =mrdata (:,:,good_subjs_idx);
megdata_good=megdata(:,:,good_subjs_idx);

%% create bands

calcbands=@(x) [x(1:(end-1)); x(2:end) ]';

meg_bands=calcbands(10.^[-2:.1:2]);
mrbands  =calcbands([ .001 .004 .007 10.^[-2:.25:-.25] ]);

%% calc alff and run correlations

mrflux   = calc_allflux(mrdata_good ,mr_freq,mrbands,{});
megflux  = calc_allflux(megdata_good,meg_freq,meg_bands,{'alf_all'}); %,'falf_all'}); -- dont need falf_all

allcorrs = calc_corrs(mrflux,megflux,{},{'alf_all'});

%% plot
mr_line_legend={'falff /(s+g+f)'     ,'alff g/1'          ,'hpfalff g/(g+f)'     ,'freqrat (s+g)/(g+f)'   };
plotdata      ={allcorrs.falf.alf_all,allcorrs.alf.alf_all,allcorrs.hpalf.alf_all,allcorrs.freqrat.alf_all};
plot_roi_band(plotdata,mr_line_legend,meg_bands)

plotdata_mats = { allcorrs.hpalf_all.alf_all, corr_meg_mr_alf,corr_meg_mr_falf};
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


