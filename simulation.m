%% simulate
mktime=@(Fs,totaltime) [0:1/Fs:totaltime-1/Fs] ;
mkdata=@(t,amp) cos(2*pi*amp*t)  + 100; % does weird thigns to welch,  but not if we normalize first
pwelnmean=@(x,win,fs) pwelch(x-nanmean(x),[],[],win,fs);
pwelch2=@(x,win,fs) pwelch(x,[],[],win,fs);

%% gen data
% MEG
amp=10; Fs=250; totaltime=260;
t=mktime(Fs,totaltime); x=mkdata(t,amp);
welchwindow=2:1:100;
[mg_x_fft,mg_x_freq]   = powerfft(x,Fs);
%[xw_fft,xw_freq] = pwelch(x,[],[],welchwindow,Fs);
%[mg_xw_fft,mg_xw_freq] = pwelnmean(x,welchwindow,Fs);
[mg_xw_fft,mg_xw_freq] = pwelch2(x,welchwindow,Fs);
% MR
amp=.3;Fs=1; totaltime=300; 
welchwindow=.02:.01:.5;
t=mktime(Fs,totaltime); x=mkdata(t,amp);
[mr_x_fft,mr_x_freq]   = powerfft(x,Fs);
%[xw_fft,xw_freq] = pwelch(x,[],[],welchwindow,Fs);
%[mr_xw_fft,mr_xw_freq] = pwelnmean(x,welchwindow,Fs);
[mr_xw_fft,mr_xw_freq] = pwelch2(x,welchwindow,Fs);

%% plot
figure;
% meg
subplot(1,2,1)
plot(mg_x_freq,mg_x_fft); 
hold on;
plot(mg_xw_freq,mg_xw_fft);
legend 'fft' 'pwelch';
title('meg');
% MR
subplot(1,2,2)
plot(mr_x_freq,mr_x_fft);
hold on;
plot(mr_xw_freq,mr_xw_fft)
legend 'fft' 'pwelch'
title('mr');

% saveas('img/welchvsfft/simulation.png')
