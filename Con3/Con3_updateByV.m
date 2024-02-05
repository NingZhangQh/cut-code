function [tC, tcor] = Con3_updateByV(tcor)
Tol = 1e-6;
tcor = uniquetol(tcor,Tol,'ByRows', true);

% get a cen
tnp  = size(tcor,1);
c    = (sum(tcor)/tnp)';

% hull
thull= convhull(tcor);
newId = zeros(tnp,1);
newId(thull) = 1;     cc = find(newId);
newId(cc)    = 1:numel(cc);

% del
tcor = tcor(cc,:);
thull= newId(thull);

% cal normal
nf = size(thull,1);
tC = zeros(nf,5);
for ii = 1:nf
    v1 = tcor(thull(ii,2),:)-tcor(thull(ii,1),:);
    v2 = tcor(thull(ii,3),:)-tcor(thull(ii,2),:);

    ia = cross(v1,v2);
    ia = ia/norm(ia);
    ib = ia*tcor(thull(ii,1),:).';

    if ia*c - ib >0
        ia = -ia;  ib = -ib;
    end
    tC(ii,2)    = ib;
    tC(ii,3:5)  = ia;
end

% due to convex
[~, ia] = uniquetol(tC, 1e-5,'ByRows',true);
tC = tC(ia,:);
end
