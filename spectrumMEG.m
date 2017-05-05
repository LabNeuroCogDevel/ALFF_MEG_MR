function SubjectRelPower = spectrumMEG( MEGTimeSeries )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
%SubjectRelPower = zeros(nROI
for Sub = 1:size(MEGTimeSeries,1)
    ThisSub = cell2mat(MEGTimeSeries(Sub,2));

    for roi = 1:14,
        clear pxx f pxxrel x
        for t = 1:2500:65000
            x = ThisSub(t:t+2500,roi);
            
            % power spectrum 
            % INPUT
            %  time series   = downsampled (detrened?) fif data
            %  window (rad/sample, spans 0 to pi)
            %  noverlap     num overlaped from section to section, def==50% 
            %  comput@freqs  = 2 to 100 in steps of 1Hz
            %  sampling freq = 250 samples per/s
            % OUTPIT
            %  pxx= power spectrum density estimate
            %  f  = frequences sampled
            [pxx f] = pwelch(x,[],[],[2:1:100],250);
            
            for i = 1:length(f)
                pxxrel(1,i) = pxx(1,i);%/sum(pxx);
            end
            SubjectRelPower(roi,ceil(t/2500),:,Sub) = pxxrel;

        end
    end
end

end

