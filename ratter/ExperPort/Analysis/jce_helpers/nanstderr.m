
function y=nanstderr(x,dim)

if nargin==1
	dim=1;
end

gd=sum(~isnan(x),dim);

y=nanstd(x,0,dim)./sqrt(gd);
y(y==Inf)=nan;