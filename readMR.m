function mrts=readMR(varargin)
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
 % files=strsplit(ls(patt),'\n');
 % sometimes there are 3 per row! this deals with that
 files= cellfun(@(x) strsplit(x,' '), strsplit(ls(patt),'\n'),'UniformOutput',0);
 % unnest
 files=[files{:}];
 
 %%  eliminate bad files (primarily, the last '')
 fidxs=cellfun(@(f) ~isempty(f) && exist(f,'file'), files);
 files=files(fidxs);

 if( length(files) < 2 ), error('too few subjects'); end
 
 % allocate
 mrts(length(files))=struct('id',0,'vdate',0,'ts',[],'age',[]);
 
 %% go through files and read in data
 for fi=1:length(files)
     f=files{fi};
     if isempty(f) || ~exist(f,'file'), continue, end
     
     % parse out id from file name
     [startofmatch,endofmatchidx]=regexp(f,'(\d{5})_(\d{8})');
     id=f(startofmatch:startofmatch+4);
     vdate=f(endofmatchidx-7:endofmatchidx);
     
     % add to struct
     mrts(fi).ts=load(f);
     mrts(fi).id=id;
     mrts(fi).vdate=vdate;
     mrts(fi).file=f;
     
 end
 
 %% add age if we can
 agetxt=fullfile(scriptdir,'txt','subj_date_age.txt');
 ages=[0 0 0];
 
 if exist(agetxt,'file')
     ages=load(agetxt); 
     % go through each visit
     for ci=1:length(mrts)
         % pull out id and date
         id=mrts(ci).id; vdate=mrts(ci).vdate;
         % try to match in agetxt
         ageidx=ages(:,1)==str2double(id) & ages(:,2)==str2double(vdate);
         age=ages(ageidx,3);
         if isempty(age); age=NaN; end
         % add what we find to the struct
         mrts(ci).age=age;
     end
     
 end
 
end
