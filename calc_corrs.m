function [ corrs ] = calc_corrs( lff1,lff2, list1,list2 )
% Calcluate correlations
%  input is two structs of fft matricies psd x roi [ x band]
%   lff1.alff = [matrix 151 x 7 x 10 ]
%   lff1.falff = [matrix 151 x 7 ]
%  and ([],[] for all) lists to compaire
%    list1={'alff','falff'} list2={'alf'"

% if list of names to use is empty, use all   
if isempty(list1); list1=fieldnames(lff1)'; end
if isempty(list2); list2=fieldnames(lff2)'; end


%% Corr
% for each roi, each meg band and each mr band, calclualte corr across subjects
%  4 combnoos
%    2d x 2d
%    2d x 3d | 3d x 2d
%    3d x 3d

for l1n = list1
    l1=l1n{1};
    d1=lff1.(l1);
    dim1=ndims(d1);
    nbands1=size(d1,3);
    if ~indim23(dim1,l1); continue; end
    nroi=size(d1,2);
    for l2n = list2
        l2=l2n{1};
        d2=lff2.(l2);
        dim2=ndims(d2);
        nbands2=size(d2,3);
        if ~indim23(dim2,l2); continue; end
        if nroi~=size(d2,2); fprintf('nroi (dim2) missmatch on %s vs %s',l1,l2); continue; end
        
        % initialize
        corrs.(l1).(l2) = squeeze(zeros(nroi,nbands1,nbands2));
        
            
      if dim1==2 && dim2==2
        for roii=1:nroi
          corrs.(l1).(l2)( roii) = corr( d1(:,roii),d2(:,roii) );
        end
        %fprintf('%s %s is 2x2 out is %d == %d\n',l1,l2,nroi,prod( corrs.(l1).(l2) ) )

      % one has bands, the other doesn't   
      elseif dim1==3 && dim2==2
          for roii=1:nroi
              for bi = 1:nbands1
                 corrs.(l1).(l2)( roii,bi) = corr( d1(:,roii,bi),d2(:,roii) );
              end             
          end
         %fprintf('%s %s is 3x2 out is %d == %d\n',l1,l2,nroi*nbands1,prod( size(corrs.(l1).(l2) ) ))

      elseif dim1==2 && dim2==3
        for roii=1:nroi
          for bi = 1:nbands2
             corrs.(l1).(l2)( roii,bi) = corr( d1(:,roii),d2(:,roii,bi) );
          end
        end
        %fprintf('%s %s is 2x3 out is %d == %d\n',l1,l2,nroi*nbands2,prod( size(corrs.(l1).(l2) ) ))

      % bands in both -- report second lff as 3rd matrix
      elseif dim1==3 && dim2==3
        for roii=1:nroi
          for b1i = 1:nbands1
              for b2i = 1:nbands2
                 corrs.(l1).(l2)(roii,b1i,b2i) = corr( d1(:,roii,b1i),d2(:,roii,b2i) );
              end
          end
        end
        %fprintf('%s %s is 3x3 out is %d == %d\n',l1,l2,nroi*nbands2*nbands1,prod( size(corrs.(l1).(l2)) ) )
        % N.B. b2i then b1i -- keep with old data strucutre!
        corrs.(l1).(l2) = permute(corrs.(l1).(l2),[1,3,2]);

      else
          fprintf('bad dims on %s (%d) vs %s (%d)\n',l1,dim1,l2,dim2) 
      end            

    end
end
 


end

function inrange=indim23(nd,n)
 inrange=ismember(nd, [2,3]);
 if(~inrange), fprintf('%s has weird ndims (%d)',n,nd); end
        
end
