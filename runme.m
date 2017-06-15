mrts=readMR();
%load('MR.mat')

[MRfft_org,mr_freq]=spectrumMR(mrts,'fft');
% TODO: reindex mat to match MEG
% want: roi  x freq x subj
% have: freq x roi x subj
%MRwelch=spectrumMR(mrts,'welch');

% save('MR.mat','MRfft','mrts')

% remove subject (11405)  not in meg
% find(cell2mat( cellfun(@(x) str2num(x)== 11405, {mrts.id} ,'UniformOutput', 0) )) == 47

% roi x psd x subj
meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat');
[MEGfft_org, meg_freq]=spectrumMEG(meg.MEGTimeSeries);


% NEED TO BE IN THE SAME ORDER and have the same number of subjects
megid = [ meg.MEGTimeSeries{:,1} ];
mrid  = [cellfun( @(x) str2num(x), {mrts.id}) ];

[megid_sort,megsubjidx] = sort(megid);
[mrid_sort,mrsubjidx]  = sort(mrid);

% remove missing meg from mr -- so both match 
missingmeg = setdiff(mrid_sort,megid_sort); % 11405
mrkeep     = mrid_sort~=missingmeg;       % not index 47 when sorted

MEGfft = MEGfft_org(:,:,megsubjidx);
MRfft  = MRfft_org (:,:,mrsubjidx(mrkeep) );
% make time by roi by subj
MEGfft_matchdim  = permute( MEGfft, [2,1,3] );

 MRfft_withinSubjnorm = meannorm_fft(MRfft);
MEGfft_withinSubjnorm = meannorm_fft(MEGfft_matchdim);





% check out our guy
% figure
% plot(meg_freq,MEGfft(5,:,8))


%% falff  alff

% index .1 to 1 by .1
%ilist=repmat([.1:.1:(1-.1)],2)'; ilist(:,2) = ilist(:,2) + .1;
%ilist2=repmat([1:1:(100-1)],2)'; ilist(:,2) = ilist(:,2) + .1;
calcbands=@(x) [x(1:(end-1)); x(2:end) ]';
%bands=10.^[-2:.1:2]; % started with .4 -- but samples too high to grab the low end (e.g. find(meg_f > .012 & meg_f < .0132) is empty)
%bands=[bands(1:(end-1)); bands(2:end) ]';
meg_bands=calcbands(10.^[-2:.1:2]);


% mrbands=calcbands(10.^[-3:.25:-.25]);
% mrbands=mrbands(3:end,:); % first few are too slow for mr_freq

% mrbands= calcbands([.001 .004 .007 .01:.02:.5 .5]);

mrbands=calcbands([ .001 .004 .007 10.^[-2:.25:-.25] ]);

nsubj=length(megid_sort); % 62
nroi=7;
nbands=length(meg_bands);
nmrbands=length(mrbands);
megfalf=zeros(nsubj,nroi,nbands);
mrfalf=zeros(nsubj,nroi);

megalf=megfalf; mralf=mrfalf;
mralf_all=zeros(nsubj,nroi,nmrbands);
mrfalf_all=mralf_all;

mr_f_idx = mr_freq > .01 & mr_freq < .1;

mrdata= MRfft;
megdata=MEGfft_matchdim;
%mrdata  = MRfft_withinSubjnorm;
%megdata = MEGfft_withinSubjnorm;

%% cacluate alff and falff
for subji = 1:nsubj
  for roii = 1:nroi
    % MR 
    mralf(subji,roii)       =  sum(mrdata(mr_f_idx,roii,subji));
    mrfalf(subji,roii)      =  sum(mrdata(mr_f_idx,roii,subji))/sum(mrdata(:,roii,subji));

    % look at _all_ mr frequeinces not just .01-.1
    mralf_all(subji,roii,:) =  calc_alff( mrdata(:,roii,subji), mr_freq,  @(x) 1, mrbands );
    mrfalf_all(subji,roii,:)=  calc_alff( mrdata(:,roii,subji), mr_freq, @nansum, mrbands );

    % MEG
    megalf(subji,roii,:)    =  calc_alff( megdata(:,roii,subji), meg_freq, @(x) 1, meg_bands );
    megfalf(subji,roii,:)   =  calc_alff( megdata(:,roii,subji), meg_freq, @nansum,meg_bands );

  end
end



% remove any nans (dropped one meg b/c too few time points)
good_subjs_idx = ~isnan(mean(squeeze(mean(megfalf,2)),2)) & ~isnan(mean(mrfalf,2));
mrfalf = mrfalf(good_subjs_idx,:);
megfalf = megfalf(good_subjs_idx,:,:);
mrfalf_all = mrfalf_all(good_subjs_idx,:,:);

mralf = mralf(good_subjs_idx,:);
megalf = megalf(good_subjs_idx,:,:);
mralf_all = mralf_all(good_subjs_idx,:,:);

nsubj=size(mrfalf,1);

% go across subjects go get roiXmeg corr for both alf and falf
corr_alf = zeros(nroi,nbands);
corr_falf= zeros(nroi,nbands);
corr_meg_mr_alf=zeros(nroi,nbands,nmrbands);
corr_meg_mr_falf=zeros(nroi,nbands,nmrbands);

%% Corr
% for each roi, each meg band and each mr band, calclualte corr across subjects
for roii=1:nroi
 for bi = 1:nbands
  corr_alf(roii,bi)  = corr( mralf(:,roii), megalf(:,roii,bi) );
  corr_falf(roii,bi) = corr( mrfalf(:,roii), megfalf(:,roii,bi) );

    for mrbi=1:nmrbands
      corr_meg_mr_alf(roii,bi,mrbi)  = corr( mralf_all(:,roii,mrbi), megalf(:,roii,bi) );
      corr_meg_mr_falf(roii,bi,mrbi) = corr( mrfalf_all(:,roii,mrbi), megfalf(:,roii,bi) );
    end

 end
end

% bandlabels={'uslow','slow','delta','theta','alpha','beta','gamma'};
% bandlabels=strsplit(sprintf('%.02e-%.02e ',meg_bands),' ');
bandlabels=cellfun(@(x) sprintf('%02.02f',x) ,num2cell(mean(meg_bands,2)),'UniformOutput',0);
roilabels={'Visual','Somatomotor','Dorsal Attention','Ventral Attention', 'Limbic','Frontoparietal','Default'};
labelintv=2;
labelidxs=0:labelintv:length(bandlabels)-1;

%%%
figure
subplot(3,1,1)
imagesc(corr_falf); colormap('jet'); caxis([-.4 .4]); colorbar;
title('falff')
set(gca,'xticklabelrotation',90,'xtick',labelidxs,'xticklabel',bandlabels(labelidxs+1))
set(gca,'yticklabel',roilabels)
subplot(3,1,2)
imagesc(corr_alf);colormap('jet'); caxis([-.4 .4]); colorbar;
title('alff')
set(gca,'xticklabelrotation',90,'xtick',labelidxs,'xticklabel',bandlabels(labelidxs+1))
set(gca,'yticklabel',roilabels)
subplot(3,1,3)
plot(1:nbands, nanmean(corr_falf,1) ); hold on
plot(1:nbands, nanmean(corr_alf,1) )
title('roi avg')
legend({'falff','alff'})
set(gca,'xticklabelrotation',90,'xtick',labelidxs,'xticklabel',bandlabels(labelidxs+1))
colorbar;
% fitlm(  nanmean(corr_falf,1),nanmean(corr_alf,1) )



% save('timeseries.mat','meg','mrts')

mrbandlabels=cellfun(@(x) sprintf('%02.03f',x) ,num2cell(mean(mrbands,2)),'UniformOutput',0);
mrlabelidxs=1:length(mrbandlabels);

figure

for i=1:nroi
 subplot(4,2,i)
 alfcormat = squeeze(corr_meg_mr_alf(i,:,:));
 MRvsMeg = permute(alfcormat,[2,1]);
 imagesc( MRvsMeg );
 colormap('jet'); colorbar;caxis([-.2 .2])
 set(gca,'ytick',mrlabelidxs,'yticklabel',mrbandlabels(mrlabelidxs))
 set(gca,'xticklabelrotation',90,'xtick',labelidxs,'xticklabel',bandlabels(labelidxs+1))
 title(sprintf('%s',roilabels{i}))
 %a=rectangle('Position',[0,2,44,4]);
 %set(a,'LineWidth',3,'EdgeColor','black')

 % zscore
 % MRvsMeg for avg below
end

subplot(4,2,8)
alfcormat = squeeze(mean(corr_meg_mr_alf,1));
imagesc( permute(alfcormat,[2,1]) );
colormap('jet'); colorbar;caxis([-.2 .2])
set(gca,'ytick',mrlabelidxs,'yticklabel',mrbandlabels(mrlabelidxs))
set(gca,'xticklabelrotation',90,'xtick',labelidxs,'xticklabel',bandlabels(labelidxs+1))
title('meg vs mr alf average')
%a=rectangle('Position',[0,2,44,4])
%set(a,'LineWidth',3,'EdgeColor','black')


