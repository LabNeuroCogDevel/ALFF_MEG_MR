function out=spectrumMR(mrts,varargin)
 %% SPECTRUMMR -- spectrum from MR time series data strcture
 % mrts=readMR()
 % method is either fft or pwelch
 % out is 3d matrix: freqbin, roi, subj
 % likely 151 x 7 x 63
 
 %% MR data
 TR=1;        % MR sampling rate in seconds
 Fs=1/TR;     % sample freq
 %N=length(ts) % number of samples, probably 300
 Nsubj = length(mrts);
 [Nsamp, Nroi]=size(mrts(1).ts);
 tsmat=reshape([mrts.ts],[Nsamp,Nroi,Nsubj]);
 freqs = 0:Fs/Nsamp:Fs/2;

 % check
 if ~all(tsmat(3,:,5) == mrts(5).ts(3,:))
     error('time series reshape does not match expected')
 end

 
 % get spectrum for each roi and subject
 Nfreq=Nsamp/2+1;
 out = zeros([Nfreq,Nroi,Nsubj]);
 for s=1:Nsubj
     if isempty(varargin) || strncmp(varargin{1}, 'fft',3)
         for r=1:Nroi
             out(:,r,s) = powerfft(tsmat(:,r,s),Fs )';
         end
     else
        out(:,:,s)=  pwelch(tsmat(:,:,s),[],[],freqs,Fs);
     end
 end
 

end
