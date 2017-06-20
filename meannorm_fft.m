function z = meannorm_fft( data )
% meannorm_fft -- divided the mean out
% expects data(samples,networks,subjects)
  nsubj=size(data,3);
  nnet=size(data,2);
  z=zeros(size(data));
  for si=1:nsubj
    %subjdata  = sqrt(data(:,:,si));
    subjdata  = data(:,:,si);
    subj_mean = mean(subjdata,2);
    %subj_std  = std(subjdata')';
    for ni=1:nnet
      z(:,ni,si) = ( subjdata(:,ni) ./ subj_mean );
    end
  end
end
