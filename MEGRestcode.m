for i = 1:size(MEG_Rest_10772.Value,1)
    TS10772DM(i,:) = detrend(TS10772(i,:),'constant');
end
%%
clear MeanSubjRelPower SubjectRelPower MeanBWSubjRelPower MeanSubjRelPowerbyNetwork
for Sub = 1:size(MEGTimeSeries,1)
    ThisSub = cell2mat(MEGTimeSeries(Sub,2));

    for roi = 1:14,
        clear pxx f pxxrel x
        for t = 1:2500:65000
            x = ThisSub([t:t+2500],roi);
            
            [pxx f] = pwelch(x,[],[],[2:1:100],250);
            
            for i = 1:length(f)
                pxxrel(1,i) = pxx(1,i);%/sum(pxx);
            end
            SubjectRelPower(roi,ceil(t/2500),:,Sub) = pxxrel;

        end
    end
end

for i = 1:size(SubjectRelPower,4)
    MeanSubjRelPowerbyNetwork(:,:,i) = nanmean(SubjectRelPower(:,:,:,i),2);
end

for i = 1:size(MeanSubjRelPowerbyNetwork,3)
    plot(MeanSubjRelPowerbyNetwork(14,:,i));
    hold on
end


for i = 1:size(MeanSubjRelPowerbyNetwork,3)
    MeanBWSubjRelPower = mean(MeanSubjRelPowerbyNetwork,3);
end

for i = 1:size(MeanBWSubjRelPower,1)
    plot(MeanBWSubjRelPower(i,:))
    hold on
    drawnow
    pause(.75)
end