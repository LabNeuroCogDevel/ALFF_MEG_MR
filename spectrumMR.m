function spectrumMR(mrts)

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
 %% MR data
 TR=1;        % MR sampling rate in seconds
 Fs=1/TR;     % sample freq
 %N=length(ts) % number of samples, probably 300
 Nsubj = length(mrts);
 [Nsamp, Nroi]=size(mrts(1).data);
 tsmat=reshape([mrts.data],[Nsamp,Nroi,Nsubj]);
 
 % check
 all(tsmat(3,:,5) == mrts(5).data(3,:));
 
 % doesn't work %arrayfun( @(x) powerfft(x,Fs), squeeze(tsmat(:,1,1)) )
 out = zeros([Nsamp/2+1,Nroi,Nsubj]);
 for r=1:Nroi
     for s=1:Nsubj
         out(:,r,s) = powerfft( tsmat(:,r,s), Fs)';
     end
 end
 
 
 
%  [psdx,freq] = powerfft(ts,Fs);
%  plot(freq,log10(psdx))
%  hold on
%  plot(downsample(freq,4),log10(downsample(psdx,4)))
%  
end
