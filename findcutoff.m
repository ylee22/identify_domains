function [ framecutoff ] = findcutoff( lifetime, numdtrajs )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

lf = [];
for i=1:numel(lifetime)
    lf = horzcat(lf, lifetime{i}(numdtrajs{i}>1));
end
histogram(log10(lf))

idx=kmeans(log10(lf)',2);

if max(lf(idx==1)) > max(lf(idx==2))
    framecutoff = [max(lf(idx==2)), min(lf(idx==1))];
else
    framecutoff = [max(lf(idx==1)), min(lf(idx==2))];
end

end

