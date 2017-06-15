function z = zscore_fft( data )
% zscore_fft -- take sqrt then mean accross networks and divide the std
% expects data(samples,networks,subjects)
  nsubj=size(data,3);
  nnet=size(data,2);
  z=zeros(size(data));
  for si=1:nsubj
    subjdata  = sqrt(data(:,:,si));
    subj_mean = mean(subjdata,2);
    subj_std  = std(subjdata')';
    for ni=1:nnet
      z(:,ni,si) = ( subjdata(:,ni) - subj_mean ) ./ subj_std;
    end
  end
end
