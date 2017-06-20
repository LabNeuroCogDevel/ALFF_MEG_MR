trmrts = readTestRetest();
ids=cellfun(@str2double,{trmrts.id});
checks = [ ...
    mod(length(trmrts),2) == 0           ... even number of things
    all([trmrts(1:2:end).scanno]==1)     ... odds are  scanno 1
    all([trmrts(2:2:end).scanno]==2)     ... evens are scanno 2
    ~any( ids(1:2:end) - ids(2:2:end) )  ... ids are paired
    ~any([trmrts(1:2:end).age] - [trmrts(2:2:end).age] ) ... ages are paired
];
if ~all(checks); stop('bad test retest data!'); end

[MRfft_org,mr_freq]=spectrumMR(trmrts,'fft');

calcbands=@(x) [x(1:(end-1)); x(2:end) ]';
mrbands=calcbands([ .001 .004 .007 10.^[-2:.25:-.25] ]);

nbands=size(mrbands,1);
nrois=size(MRfft_org,2);


llf.trmr1 = calc_allflux( MRfft_org(:,:,1:2:end), mr_freq,mrbands,[] );
llf.trmr2 = calc_allflux( MRfft_org(:,:,2:2:end), mr_freq,mrbands,[] );


cs=struct();
for fn=fieldnames(llf.trmr1)
    for roii=1:nroi
     for bi = 1:nbands
        d1= llf.trmr1.(fn{1})(:,roii,bi);
        if ndims(d1)==3, nbands2=nbands; else nbands2=1; end
        for bj=1:nbands2
          d2=llf.trmr2.(fn{1})(:,roii,bj);
          
          
        end
     end
    end
end