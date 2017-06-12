function [psdx,freq] = powerfft(x,Fs)
 % x = timeseries
 % FS = e.g. 250
 %
 % Code from
 % http://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
 
 x = x - nanmean(x);       % demean (DM+FC 20170504)
 N = length(x);
 xdft = fft(x);           % fourier
 poshalflen=N/2+1;
 %fprintf('N = %d  half+1 = %d\n',N,poshalflen);
 xdft = xdft(1:poshalflen);    % only need power estimates for the positive, first half 
 
 % I don't know why we do this :)
 % complex to real
 psdx = (1/(Fs*N)) * abs(xdft).^2;
 
 % DM revised 20170504 -- remove scaling factor to compare with pwelch
 % psdx =abs(xdft).^2;

 
 % conserve the total power, multiply by 2. 
 % Zero frequency (DC) (idx=1) and the Nyquist frequency(idx=end) do not occur twice.
 psdx(2:end-1) = 2*psdx(2:end-1); 
 freq = 0:Fs/length(x):Fs/2;
end

% octave doesn't have nanmean
% function m=nanmean(x)
%  m=mean( x(~isna(x) & ~isnan(x) ));
% end
