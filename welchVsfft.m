load('timeseries.mat'); % meg, mrts

% todo remove missing subject

mr_subj8_5 = mrts(6).ts(:,5);

meg_subj8_5_1 = meg.MEGTimeSeries{8,2}(:,9);
meg_subj8_5_2 = meg.MEGTimeSeries{8,2}(:,10);

% all roi
meg_sub8 = meg.MEGTimeSeries{8,2};
meg_8_fft = arrayfun(@(x) powerfft(meg_sub8(:,x),250), 1:14, 'UniformOutput',0));


plot((mr_subj8_5); title('mr ts');
figure; plot([meg_subj8_5_1, meg_subj8_5_2]); title('meg ts')

%% compute power and visualize
[mrp ,mr_f ] = powerfft(mr_subj8_5,1);
[megp,meg_f] = powerfft(meg_subj8_5_1,250);
figure;
subplot(1,2,1); plot(mr_f ,mrp ); title('mr')
subplot(1,2,2); plot(meg_f,megp); title('meg')


% meg_chunked = arrayfun(@(x) powerfft( meg_subj8_5_1(x:x+2500 -1), 250 ), [1:2500:65000] , 'UniformOutput',0);
% avg_chunked = mean(cell2mat(meg_chunked),2);


%% effect of resampling/averaging data with fft
% SM WF 20170612
windowsizes= 250 * [ 260 30 10 5 3]; % 5sec chunks
figure; hold on;
for i=1:length(windowsizes)
  windowsize=windowsizes(i);
  [~,meg_chunk_f] = powerfft(meg_subj8_5_1(1:(1+windowsize) -1), 250 );
  meg_chunked_w = arrayfun(@(x) powerfft( meg_subj8_5_1(x:(x+windowsize -1)), 250 ), [1:windowsize:65000] , 'UniformOutput',0);
  avg_chunked_w = mean(cell2mat(meg_chunked_w),2);
  hold on;
  plot(meg_chunk_f,avg_chunked_w)
end
legend(strsplit(num2str(windowsizes)))


%% FAALF
% MR: .01 - .1 / all 
mr_f_idx = mr_f > .01 & mr_f < .1;
mr_falf  = sum(mrp(mr_f_idx))/sum(mrp)
% MEG
megfalffreq = ...
[ .01 .1; ... ultra slow 
   .1  1; ... slow
    1  3; ... delta
    3  8; ... theta
    8 14; ... alpha
   14 30; ... beta
   30 100;... gama
];
nmegfreq = size(megfalffreq,1)
meg_falf = zeros(1,nmegfreq);
meg_totalpower=sum(megp);
for fi = 1:nmegfreq
  low  = megfalffreq(fi,1);
  high = megfalffreq(fi,2);
  meg_falf_idx = meg_f > low & meg_f < high;
  %range(find(meg_falf_idx))
  meg_falf(fi) = sum(megp(meg_falf_idx))/meg_totalpower;
end



% bold signal .01 - .1 Hz  (1/100 seconds, minum. 300s for 3 points)
% meg infaslow 


megwindow = [2:1:100];
[meg_welch meg_welch_f] = pwelch(meg_subj8_5_1,[],[],megwindow,250);
plot(meg_welch_f,meg_welch); title('meg welch')
%

[Pxx,W] = periodogram( meg_subj8_5_1,[],250)


[mr_welch mr_welch_f] = pwelch(mr_subj8_5,[],[],[.0001:.005:.5],1);
plot(mr_welch_f,mr_welch); title('mr welch')




figure
subplot(2,2,1)
plot(meg_f,megp); title('meg fft psd')
subplot(2,2,2)
plot(mr_f,mrp); title('mr fft psd')
subplot(2,2,3)
plot(meg_welch_f,meg_welch); title('meg pwelch')
subplot(2,2,4)
plot(mr_welch_f,mr_welch); title('mr pwelch')



