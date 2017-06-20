function [ figid ] = plot_roi_band(corrdatacell,datalegend, bands )
%plot_roi_band plot rois against bands
%   Detailed explanation goes here

    %% labels
    % datalegend={'falff /(s+g+f)','alff g/1','hpfalff g/(g+f)','freqrat (s+g)/(g+f)'};
    % bands=meg_bands


    % y label
    roilabels={'Visual','Somatomotor','Dorsal Attention','Ventral Attention', 'Limbic','Frontoparietal','Default'};
    
    % x label
    % bandlabels={'uslow','slow','delta','theta','alpha','beta','gamma'};
    % bandlabels=strsplit(sprintf('%.02e-%.02e ',meg_bands),' ');
    nbands=size(bands,1);
    bandlabels=cellfun(@(x) sprintf('%02.02f',x) ,num2cell(mean(bands,2)),'UniformOutput',0);
    labelintv=2;
    labelidxs=0:labelintv:nbands-1;
    
    
    figid=figure;
    %% correlation subplots
    ncorrplots=length(corrdatacell);
    for i=1:ncorrplots
        subplot(ncorrplots+1,1,i)
        imagesc(corrdatacell{i});
        title(datalegend{i});
        set(gca,'yticklabel',roilabels);
        xlab();
        colormap('jet'); caxis([-.4 .4]); colorbar;
    end
    
    %% line plot of averages
    subplot(ncorrplots+1,1,ncorrplots+1)
    hold off;
    for i=1:ncorrplots
      plot(1:nbands, nanmean(corrdatacell{i},1) ); hold on
    end
    xlab();
    title('roi avg')
    legend(datalegend)
    suptitle('mr against meg alf') %from bioinfo; aligns line plot w/o colorbar too

    %% rather than type it twice
    function xlab()
        set(gca,'xticklabelrotation',90,'xtick',labelidxs,'xticklabel',bandlabels(labelidxs+1))
    end
end