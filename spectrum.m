function s = spectrum(ts3d,Fs,chunksize,welch_window)
 % SPECTRUM - comupte fft + pwelch with and without chunking
 %  ts3d is [ts x roi x subj ]
 %  fs is sampling frequences (250 for meg, 1 for mr)
 %  chunksize is how many samples to put into a chunk

 % anon. fun to normalize before fft with pwelch
 pwelnmean=@(x) pwelch(x-nanmean(x),[],[],welch_window,Fs);
 % anon. fun to simplify call to powerfft
 pfft=@(x)      powerfft(x,Fs);

 % get and check input timeseries matrix size
 [N,nroi,nsubj]= size(ts3d);
 if (N< nroi || N < nsubj || nsubj < nroi )
   error('input matrix is probably not ts x roi x subj');
 end

 % anon function to run for each roi
 each_roi = @(subj,fun) ...
                arrayfun(@(roii) fun( subj(:,roii) ) ),...
                1:nroi,...
                'UniformOutput',0));

 % run each subject through the function that will run power through each roi
 run_entire=@(fun) arrayfun(...
     @(subji,fun) cell2mat( each_roi(ts3d(:,:,subji) , fun) ),...
     1:nsubj, ...
     'UniformOutput',0);

 s.fft   = run_entire(pfft); 
 s.pwlch = run_entire(pwelnmean); 

end
