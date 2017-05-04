%% NOTEBOOK

%% get data
mrts=readMR();

%% time series
tsfig=figure;
ts = mrts(1).ts(:,1);
plot(ts);

%% pwelch vs fft
normts=ts-nanmean(ts); % powerfft norms, so do the same to welch
Nts=numel(ts);
% via fft
[ap, fp] = powerfft(ts,1);
% via welch
[aw fw]=pwelch(normts,Nts,[],fp,1);

all(fw==fp) % freq bins are the same

% plot
allfig=figure;

subplot(221);hold on;
plot(fp,log10(ap)); plot(fp,log10(aw));
title('log10 power')
legend({'fft','welch'},'Orientation','horz','Location','SouthEast')
ylim([-3,6])

subplot(222)
scatter(log10(ap(2:end)),log10(aw(2:end)),'k')
xlabel('fft'); ylabel('weltch'); title('log compare, no DC')
ylim([0,5]);xlim([0,5])

subplot(223)
plot(ts,'g'); title('time series')

subplot(224); hold on;
plot(fp,ap); plot(fp,aw);
title('power')
legend({'fft','welch'},'Orientation','vert','Location','NorthEast')

saveas(allfig,'img/welch_vs_fft.png')
