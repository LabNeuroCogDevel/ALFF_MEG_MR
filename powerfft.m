function [psdx,freq] = powerfft(x,Fs)
 % Code from
 % http://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
 N = length(x);
 xdft = fft(x);           % fourier
 xdft = xdft(1:N/2+1);    % only need power estimates for the positive, first half 
 
 % I don't know why we do this :)
 % complex to real
 psdx = (1/(Fs*N)) * abs(xdft).^2;
 
 % conserve the total power, multiply by 2. 
 % Zero frequency (DC) (idx=1) and the Nyquist frequency(idx=end) do not occur twice.
 psdx(2:end-1) = 2*psdx(2:end-1); 
 freq = 0:Fs/length(x):Fs/2;
end
