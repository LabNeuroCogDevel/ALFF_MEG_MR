mrts=readMR();

[MRfft,mr_freq]=spectrumMR(mrts,'fft');
% TODO: reindex mat to match MEG
% want: roi  x freq x subj
% have: freq x roi x subj
%MRwelch=spectrumMR(mrts,'welch');

save('MR.mat','MRfft','mrts')

% remove subject (11405)  not in meg
% find(cell2mat( cellfun(@(x) str2num(x)== 11405, {mrts.id} ,'UniformOutput', 0) )) == 47
MRfft_org = MRfft;
MRfft = MRfft_org(:,:,[1:46,48:63]);

meg=load('/Volumes/Zeus/meg/MMY4_rest/MEGTimeSeries.mat')
megid = [ meg.MEGTimeSeries{:,1} ]

% roi x psd x subj
[MEGfft, meg_freq]=spectrumMEG(meg.MEGTimeSeries);

plot(meg_freq,MEGfft(5,:,8))

%% meg falf
nsubj=62;
nroi=7;
nbands=7;
megfalf=zeros(nsubj,nroi,nbands);
mrfalf=zeros(nsubj,nroi);

megalf=megfalf; mralf=mrfalf;

mr_f_idx = mr_f > .01 & mr_f < .1;
for subji = 1:nsubj
  for roii = 1:nroi
    megalf(subji,roii,:) = meg_falff( MEGfft(roii,:,subji), meg_freq, @(x) 1 );
    mralf(subji,roii)    =  sum(MRfft(mr_f_idx,roii,subji));

    megfalf(subji,roii,:) = meg_falff( MEGfft(roii,:,subji), meg_freq, @nansum );
    mrfalf(subji,roii)    =  sum(MRfft(mr_f_idx,roii,subji))/sum(MRfft(:,roii,subji));
  end
end

% remove any nans (dropped one meg b/c too few time points)
good_subjs_idx = ~isnan(mean(squeeze(mean(megfalf,2)),2)) & ~isnan(mean(mrfalf,2));
mrfalf = mrfalf(good_subjs_idx,:);
megfalf = megfalf(good_subjs_idx,:,:);
mralf = mralf(good_subjs_idx,:);
megalf = megalf(good_subjs_idx,:,:);
nsubj=size(mrfalf,1);

corr_alf = zeros(nroi,nbands);
corr_falf= zeros(nroi,nbands);
for roii=1:nroi
 for bi = 1:nbands
  corr_alf(roii,bi) = corr( mralf(:,roii), megalf(:,roii,bi) );
  corr_falf(roii,bi) = corr( mrfalf(:,roii), megfalf(:,roii,bi) );
 end
end

roilabels={'Visual','Somatomorto','Dorsal Attention','Ventral ATtention', 'Limbic','Frontoparietal','Default'};

subplot(2,1,1)
imagesc(corr_alf)
set(gca,'xticklabel',{'uslow','slow','delta','theta','alpha','beta','gamma'})
subplot(2,1,2)
plot(1:7, mean(corr_alf,1) )
set(gca,'xticklabel',{'uslow','slow','delta','theta','alpha','beta','gamma'})
set(gca,'yticklabel',roilabels)


figure

subplot(2,1,1)
imagesc(corr_falf); colormap('jet'); caxis([-.3 .3]); colorbar;
set(gca,'xticklabel',{'uslow','slow','delta','theta','alpha','beta','gamma'})
set(gca,'yticklabel',roilabels)
title('falff')
subplot(2,1,2)
imagesc(corr_alf);colormap('jet'); caxis([-.3 .3]); colorbar;
title('alff')
set(gca,'xticklabel',{'uslow','slow','delta','theta','alpha','beta','gamma'})
set(gca,'yticklabel',roilabels)






save('timeseries.mat','meg','mrts')
