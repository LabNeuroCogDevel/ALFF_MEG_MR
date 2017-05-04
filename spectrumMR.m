function out=spectrumMR(mrts)
 %% SPECTRUMMR -- spectrum from MR time series data strcture
 % mrts=readMR()
 % out is 3d matrix: freqbin, roi, subj
 % likely 151 x 7 x 63
 
 %% MR data
 TR=1;        % MR sampling rate in seconds
 Fs=1/TR;     % sample freq
 %N=length(ts) % number of samples, probably 300
 Nsubj = length(mrts);
 [Nsamp, Nroi]=size(mrts(1).ts);
 tsmat=reshape([mrts.ts],[Nsamp,Nroi,Nsubj]);
 
 % check
 if ~all(tsmat(3,:,5) == mrts(5).ts(3,:))
     error('time series reshape does not match expected')
 end

 
 % get spectrum for each roi and subject
 Nfreq=Nsamp/2+1;
 out = zeros([Nfreq,Nroi,Nsubj]);
 for r=1:Nroi
     for s=1:Nsubj
         out(:,r,s) = powerfft( tsmat(:,r,s), Fs)';
     end
 end
 
 %% plotting
 % get freq by redoing just one
 [~, freq ] = powerfft( tsmat(:,1,1), Fs);
 
 % all rois for subj 63
 plot(freq,log10(out(:,:,63)))
 % all subjs maen for roi 7
 plot(freq,mean(squeeze(log10(out(:,7,:))),2))
 
 % network roi labels
 % https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3174820/figure/F12/
 labels={'Visual','Somatomotor','DorsalAtt','VentralAtt',...
         'limbic','Frontoparietal','Default'};
 
 % freq range we care about .01-.08
 bandpassidx = freq>=.01 & freq<=.08;    
     
 % collapse all subjects into an roi time series
 roits=mean(out,3);
 % rescale and only look at bandpass range
 roitsbplog = 10*log10(roits(bandpassidx,:));
 % make a table so corrplot has labels
 d = array2table(roitsbplog,'VariableNames',labels);
 corrplot(d)
 


%  
end

%% JUNK
% ts like
 % c=readMR();
 % ts=c(1).data(:,1);
 %% power spectrum TOY
%  Fs=1000;                 % sample freq
%  t=0:1/Fs:1 - 1/Fs;       % time points (1000 samples)
%  speed=200;               % Hz
%  x = sin(2*pi*t*speed);     % our time series @ 100 Hz
%  [psdx,freq] = powerfft(x,Fs);
%  
%  % as dB
%  psdxdB=10.*log10(psdx);
%  plot(freq,psdxdB) 
%  

%  [psdx,freq] = powerfft(ts,Fs);
%  plot(freq,log10(psdx))
%  hold on
%  plot(downsample(freq,4),log10(downsample(psdx,4)))
