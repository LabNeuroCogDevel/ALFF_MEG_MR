function SubjectRelPower = spectrumMEG( MEGTimeSeries )
%SPECTRUMMEG  calcualte power spectrum of MEG data (pwelch, copied from SM 2016)
% calculate power spectrum over intervals of bin_time for total_time (assuming sampfreq)
% return matrix: roi x windownumber x freq x Sub

sampfreq      = 250; % per second, "raw" data
bin_time      = 10;  % seconds, break up the data into 10s bins
total_time    = 260; % seconds, dont use more than 260s of data

total_samples = total_time*sampfreq; % 65000
samples_in_bin=bin_time*sampfreq;  %  2500

for Sub = 1:size(MEGTimeSeries,1)
    ThisSub = cell2mat(MEGTimeSeries(Sub,2));

    total_used_samples= total_samples;
    subj_samples      = size( ThisSub,1);

    % subject should have at least as many samples as we want to inspect
    if subj_samples < total_samples
      warning('subj no %d has too few samples (%d)',Sub,subj_samples)
      %Warning: subj no 39 has too few samples (56250) 

      % use only full bins
      total_used_samples=floor(subj_samples/samples_in_bin)*samples_in_bin;
    end
    % lateral version of Yeo7 
    for roi = 1:14,
        clear pxx f pxxrel x
        % go through time (by sample) in 2500 chunks
        % only use at most 65000 total samples
        for t = 1:samples_in_bin:total_used_samples %1:2500:65000
            x = ThisSub(t:t+samples_in_bin,roi);
            
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
            [pxx f] = pwelch(x,[],[],[2:1:100],sampfreq);
            
            %  -- WF 20170507 --
            % this does nothing?
            % pxx and pxxrel are 1D
            % for loop used previously to averaged
            % now only last bin is used
            %  -- --
            % for i = 1:length(f)
            %     pxxrel(1,i) = pxx(1,i);%/sum(pxx);
            % end
            % % also written as 
            % % pxxrel = pxx ./ sum(pxx)

            windownumber=ceil(t/samples_in_bin);
            SubjectRelPower(roi,windownumber,:,Sub) = pxx;

        end
    end
end

end

