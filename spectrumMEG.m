function [bilat_winavg, f] = spectrumMEG( MEGTimeSeries )
%SPECTRUMMEG  calcualte power spectrum of MEG data (pwelch, copied from SM 2016)
% calculate power spectrum over intervals of bin_time for total_time (assuming sampfreq)
% return matrix: roi x windownumber x freq x Sub

sampfreq      = 250; % per second, "raw" data
bin_time      = 10;  % seconds, break up the data into 10s bins
bin_time      = 260;  % seconds, use all the data
total_time    = 260; % seconds, dont use more than 260s of data

total_samples = total_time*sampfreq; % 65000
samples_in_bin=bin_time*sampfreq;  %  2500

%% TODO:
% mean timeseries BEFORE fft calculation
%
for Sub = 1:size(MEGTimeSeries,1)
    ThisSub = cell2mat(MEGTimeSeries(Sub,2));

    total_used_samples= total_samples;
    subj_samples      = size( ThisSub,1);

    % subject should have at least as many samples as we want to inspect
    if subj_samples < total_samples
      % subj 39 has too few sampesl 56250 != 65000
      warning(sprintf('subj (%d) has too few samples %d != %d\n',Sub,subj_samples,total_samples))
      % use only full bins
      total_used_samples=floor(subj_samples/samples_in_bin)*samples_in_bin;
    end
    % lateral version of Yeo7 
    for roi = 1:14,
        % clear pxx f pxxrel x

        % go through time (by sample) in 2500 chunks (10s bins)
        % only use at most 65000 total samples
        for t = 1:samples_in_bin:total_used_samples %1:2500:65000
            endindex=t+samples_in_bin-1; % start at t, go nsamples, minus 1 b/c next starts at t+nsamples
            x = ThisSub(t:endindex,roi);
            
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

            % % matlab : TODO -- test implementation
            % [pxx f] = pwelch(x,[],[],[2:1:100],sampfreq);
            % % octave, Nfft smaller silently ignored
            % %[pxx f] = pwelch(x,[],.5,0,sampfreq,'half');
            % % x,window,overlap,Nfft,Fs,range,plot_type,detrend,sloppy
            

            % FFT instead of welch
            [pxx,f] = powerfft(x,sampfreq);

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

%% collapse data
% average over all power windows
winavg =squeeze(mean(SubjectRelPower,2));
% average L/R rois to get bilateral rois
% pairs are like 1,2  3,4  etc
bilat_winavg = ( winavg(1:2:13,:,:) + winavg(2:2:14,:,:) )/2;

% %CONFIRM ROI is every other
% figure; hold on;
% c='rgbcmyk';
% for i=1:7
%  plot(bilat(i,:,3),c(i));
%  bidx=(i-1)*2 + [1:2];
%  plot(m(bidx,:,3)','--','color',c(i));
% end

end


