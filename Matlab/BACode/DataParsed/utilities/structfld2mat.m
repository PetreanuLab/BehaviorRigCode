function matOut = structfld2mat(dp,fldname)

ndp = length(dp);
matOut = nan(ndp,size(dp(1).(fldname),2));
for idp = 1:ndp
    matOut(idp,:) = dp(idp).(fldname);   
end