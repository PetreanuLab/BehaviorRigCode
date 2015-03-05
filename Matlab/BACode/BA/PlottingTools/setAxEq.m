function setAxEq(h,whichax,mode)
% function setAxEq(h,whichax,mode)
% BA 
% mode = 'matchFirstAxis'
if nargin <1
    h = gca;
    mode = '';
end
if nargin <2
    whichax = 'xy';
    mode = '';
end

if nargin<3
    mode = '';
end
switch (whichax)
    
    case 'xy'
        helper(h,'xlim',mode);
        helper(h,'ylim',mode);
    case 'x'
        helper(h,'xlim',mode);
    case 'y'
        helper(h,'ylim',mode);
        
end

function lim = helper(h,str,mode)

m = get(h,str);
switch (mode)
    case 'matchFirstAxis'
        lim = m{1};
    otherwise
        if iscell(m)
            lim(1) = min(cellfun(@min,m));
            lim(2) = max(cellfun(@max,m));
        else
            lim = m;
        end
end
set(h,str,lim);
