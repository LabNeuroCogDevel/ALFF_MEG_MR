function c=readMR(varargin)
 %% READMR ret

 scriptdir=fileparts(mfilename('fullpath'));
 
 %% look in 2 dirs up from here or specify a pattern
 if(~isempty(varargin))
     patt=varargin{1};
 else
     
     % file is in script directory, so fileparts twice to get back one
     % directory
     roitxtfile='Y7_3mm_roistat.txt';
     root=fileparts(scriptdir);
     patt=fullfile(root,'subjs','*','fALFF',roitxtfile);
     %looks like
     %patt='/Volumes/Zeus/WF_ALFF/full/subjs/*/fALFF/Y7_3mm_roistat.txt';

 end
 
 %% find all roistat files
 files=strsplit(ls(patt),'\n');
 
 %%  eliminate bad files (primarily, the last '')
 fidxs=cellfun(@(f) ~isempty(f) && exist(f,'file'), files);
 files=files(fidxs);
 
 %% go through files and read in data
 for fi=1:length(files)
     f=files{fi};
     if isempty(f) || ~exist(f,'file'), continue, end
     
     [ididx,vdateidx]=regexp(f,'(\d{5})_(\d{8})');
     id=f(ididx:ididx+4);
     vdate=f(vdateidx:vdateidx+7);
     c(fi).data=load(f);
     c(fi).id=id;
     c(fi).vdate=vdate;
 end
 
 
end