%% shared things
% bands
calcbands=@(x) [x(1:(end-1)); x(2:end) ]';
meg_bands=calcbands(10.^[log10(.5):.1:2]);
mr_bands  =calcbands(10.^[-2:.25:-.25] );
% band labels
meg_band_labels=cellfun(@(x) sprintf('%02.02f',x) ,num2cell(mean(meg_bands,2)),'UniformOutput',0);
labelintv=2; meg_labelidxs=0:labelintv:length(meg_band_labels)-1;

mr_band_labels=cellfun(@(x) sprintf('%02.03f',x) ,num2cell(mean(mr_bands,2)),'UniformOutput',0);
mr_labelidxs=1:length(mr_band_labels);




%%% MMY4 mr vs meg

%% read in data

% load various MR preproc  
mrts.Orig  =readMR();
mrts.MotPC =readMR('/Volumes/Zeus/ALFF/full/subjs/*/fALFF/DM_Y7_3mm_roistats.txt');
mrts.MotReg=readMR('/Volumes/Zeus/ALFF/full/subjs/*/fALFF/simpmot_Y7_3mm_roistats.txt');


% load meg data 
meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat');
[MEGfft_org, meg_freq]=spectrumMEG(meg.MEGTimeSeries,6); % 10sec bins; NB. roi x psd x subj
megid = [ meg.MEGTimeSeries{:,1} ];


% for each MR preproc time series
for fn=fieldnames(mrts)'
  [MRfft_org,mr_freq]=spectrumMR(mrts.(fn{1}),'fft');  
  mrid  = cellfun( @(x) str2double(x), {mrts.(fn{1}).id}) ;
  [mrdata.(fn{1}),megdata_good ] = matchMRMEG(MRfft_org,MEGfft_org,mrid,megid);
  mrflux   = calc_allflux(mrdata.(fn{1}) ,mr_freq,mr_bands,{});
  % meg data isn't changing, maybe dont need to do this each time
  megflux  = calc_allflux(megdata_good,meg_freq,meg_bands,{'alf_all'});
  
  allcorrs.(fn{1}) = calc_corrs(mrflux,megflux,{},{'alf_all'});
  
end

%% plot
for fnn = {'Orig','MotReg','MotPC'}
    fn=fnn{1};
    mr_line_legend={'falff /(s+g+f)'     ,'alff g/1'          ,'hpfalff g/(g+f)'      ,'freqrat (s+g)/(g+f)'   };
    plotdata      ={allcorrs.(fn).falf.alf_all,allcorrs.(fn).alf.alf_all,allcorrs.(fn).hpfalf.alf_all,allcorrs.(fn).freqrat.alf_all};
    netlines.(fn) = plot_roi_band(plotdata,mr_line_legend,meg_bands);
    netlines.(fn).Visible='Off';
    
    plotdata_mats = { allcorrs.(fn).alf_all.alf_all}; % ,allcorrs.(fn).hpfalf_all.alf_all, allcorrs.(fn).falf_all.alf_all
    plotlabel_mats = {  'meg vs mr alf'};
    %plotlabel_mats = { 'hpalf vs meg alf', 'meg vs mr alf','mr falf vs meg alf'};

    matplots.(fn)=plot_band_band_roi( plotdata_mats, plotlabel_mats, meg_labelidxs,meg_band_labels, mr_labelidxs,mr_band_labels );
    suptitle(fn)
    matplots.(fn).Visible='Off';
end

fns=fieldnames(netlines)';
nfigs=length(fns);
nsubp=4;
lnplt = figure;
cnt=1;
for i=1:nfigs; 
    h=findobj(netlines.(fns{i}),'type','axes');
    for k=[2,4:6];
        axcpy = copyobj(h(k),lnplt);
        subplot(nfigs,nsubp,cnt, axcpy );
        cnt=cnt+1;
    end
end
%set(0,'DefaultFigureVisible','on');


matalf.motpc = plot_band_band_roi( {allcorrs.MotPC.alf_all.alf_all}, {'MotPC alfall'}, meg_labelidxs,meg_band_labels, mr_labelidxs,mr_band_labels );
matalf.orig = plot_band_band_roi( {allcorrs.Orig.alf_all.alf_all}, {'Orig alfall'}, meg_labelidxs,meg_band_labels, mr_labelidxs,mr_band_labels );


