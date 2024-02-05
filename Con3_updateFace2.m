%{
计算多面体的面（张宁 202312）
输入
    tC 凸多面体的tC = [b, A]
    tcor 凸多面体所有的顶点
输出
    tC 凸多面体的tC
%}
function [tC, tF] = Con3_updateFace(tC, tcor)
tol= 1e-6;
nf= size(tC,1);

% faces
tF = cell(nf,1);     % tf_cn = zeros(nf,6);

isEffect = true(nf,1);
for ii = 1:nf
    % find points on face
    a = tC(ii,3:5);    b = tC(ii,2);
    ips = find(abs(a*tcor'-b) < tol);
    if numel(ips) < 3 
        isEffect(ii) = false;
        continue
    end
 
    % sort by cor and normal
    tF{ii} = ips(sub_sortFaceP(tcor(ips,:), a));
end

if sum(isEffect) < 4
    tC = [];  tF =[];
else
    tC=tC(isEffect,:);
    tF = tF(isEffect);     
end

end

% sortFace by normal
function newid = sub_sortFaceP(cors, n)

vs = cors - cors(1,:);   
n2 = vs(2,:);
n3 = [n(2)*n2(3)-n(3)*n2(2), n(3)*n2(1)-n(1)*n2(3), n(1)*n2(2)-n(2)*n2(1)];

ys = vs * n2';
zs = vs * n3';
newid2 = sub_sortFacePbak(cors,  n);

vAngle = atan2(zs, ys);

[vAngle, newid] = sort(vAngle);
newid = newid2;
if norm(newid - newid2) > 0.01
    cc=1
end
end


% sortFace by normal
function newid = sub_sortFacePbak(cors,  normal)
ips = 1:size(cors,1);
tnp= numel(ips);
p0 = cors(ips(1),:);

% cal others relating p0
v0s = cors - p0;    v0s = v0s./(vecnorm(v0s,2,2));
v01 = v0s(2,:);

% angles
vAngle = zeros(tnp,1);
for jj = 2:tnp
    angle = acos(sum(v0s(jj,:).*v01));
    % positve volum
    if sub_volume(v01, v0s(jj,:), normal) >= 0
        vAngle(jj) = angle; % 1 2
    else
        vAngle(jj) = 2*pi-angle; % 3,4
    end
end

[~, newid] = sort(vAngle);
end

% get volume
function V = sub_volume(va, vb, vc)
V = vc(3)*(va(1)*vb(2)-va(2)*vb(1))...
    + vc(1)*(va(2)*vb(3)-va(3)*vb(2))...
    + vc(2)*(va(3)*vb(1)-va(1)*vb(3));
end

