function lff = calc_allflux(data,freq,bands,list_to_calc)
%
%  
% mrbands=calcbands([ .001 .004 .007 10.^[-2:.25:-.25] ]);

    % if ndims(data2)~=3 || ndims(data1)~=3; 
    %  stop('provided data inputs are not both 3 dimensions' );
    % end
    % if size(data1,2)~=size(data2,2) ||  size(data1,3)~=size(data2,3);
    %   stop('provided data inputs do not match roi/network number or subj number')
    % end
    
    if ndims(data)~=3; stop('bad input ts data (ndim=~3'); end
    
    %% data extents
    [nsteps, nroi, nsubj] =size(data);
    nbands=size(bands,1);

    %% initiialze data
    fi_at = @(l,h) freq >= l & freq < h;
    measures = { ...
      ... name, dims, function on data(:,subji,roii) for dataset freq f and possibly grouped by bands
      {       'alf',2, @(d,~) sum( d( fi_at(.01, .1) ))                          }, ... 
      {      'falf',2, @(d,~) sum( d( fi_at(.01, .1) ))/sum( d(         2:end  ) ) }, ...
      {    'hpfalf',2, @(d,~) sum( d( fi_at(.01, .1) ))/sum( d( fi_at(.01,Inf) ) ) }, ...
      {   'freqrat',2, @(d,~) sum( d( fi_at(.001,.1) ))/sum( d(         2:end  ) ) }, ...
      ...
      {   'alf_all',3, @(d,b) calc_alff( d,freq, @(x) 1  , b ) }, ...
      {  'falf_all',3, @(d,b) calc_alff( d,freq, @nansum , b ) }, ...
      {'hpfalf_all',3, @(d,b) calc_alff( d,freq, @(x) sum( d(fi_at(.01,Inf)) ), b ) }
    };

    %% what 
    allmeasurenames=cellfun(@(x) x{1},measures,'UniformOutput',0);
    if isempty(list_to_calc), list_to_calc=allmeasurenames;end;
    measuresidx = find( ismember(allmeasurenames, list_to_calc) );
    
    %% allocate
    % note dims: 
    %   input:  steps x roi x subj
    %   output: subj  x roi x bands (last only sometimes)
    s=[nsubj,nroi,nbands];
    for mi = measuresidx
      m=measures{mi};
      lff.( m{1} ) = zeros( s(1:m{2}) );
    end

    %% for each subject and network (roi): cacluate spectrum measures (falff, alff)
    for subji = 1:nsubj
      for roii = 1:nroi
          dsr=data(:,roii,subji);
          for mi = measuresidx
            mname=measures{mi}{1};
            mfunc=measures{mi}{3};
            lff.(mname)(subji,roii,:) = mfunc(dsr,bands);
          end
       end
    end
end


