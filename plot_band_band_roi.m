function fidids = plot_band_band_roi( loopdata, looplabel, xidx,xlab,yidx,ylab )
%plot_band_band_roi --
%
    % TODO: ylab and xlab
    % x: mrlabelidxs mrbandlabels(mrlabelidxs))
    % y: labelidxs bandlabels(labelidxs+1)
    
    roilabels={'Visual','Somatomotor','Dorsal Attention','Ventral Attention', 'Limbic','Frontoparietal','Default'};
    nroi=7;
    

    for dataidx = 1:length(looplabel); 
      corrdata=loopdata{dataidx};
      fidids(dataidx) = figure;

      for i=1:nroi
       subplot(4,2,i)
       alfcormat = squeeze(corrdata(i,:,:));
       MRvsMeg = permute(alfcormat,[2,1]);
       imagesc( MRvsMeg );
       labelall()
       title(sprintf('%s',roilabels{i}))
       %a=rectangle('Position',[0,2,44,4]);
       %set(a,'LineWidth',3,'EdgeColor','black')

       % zscore
       % MRvsMeg for avg below
      end

      subplot(4,2,nroi+1)
      alfcormat = squeeze(mean(corrdata,1));
      imagesc( permute(alfcormat,[2,1]) );
      labelall()
      title('meg vs mr alf average')
      suptitle(looplabel{dataidx}); % super label from bioinfo toolbox

      % TODO -- add these lines to mark .01 to .1 (hrf) back in!
      %a=rectangle('Position',[0,2,44,4])
      %set(a,'LineWidth',3,'EdgeColor','black')
    end

    function labelall()
       colormap('jet'); colorbar;caxis([-.4 .4])
       set(gca,'ytick',yidx,'yticklabel',ylab(yidx))
       set(gca,'xticklabelrotation',90,'xtick',xidx,'xticklabel',xlab(xidx+1))
    end
end


