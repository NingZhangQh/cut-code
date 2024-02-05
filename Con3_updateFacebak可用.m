%{
计算多面体的面（张宁 202312）
输入
    tC 凸多面体的tC = [b, A]
    tcor 凸多面体所有的顶点
输出
    tC 凸多面体的tC
%}
function [tC, tf_P] = Con3_updateFace(tC, tcor)
tol= 1e-6;
nf= size(tC,1);

% faces
tf_P = cell(nf,1);     % tf_cn = zeros(nf,6);

isEffect = true(nf,1);
for ii = 1:nf
    % 找面上的点 
    a = tC(ii,3:5);    b = tC(ii,2);
    ips = find(abs(a*tcor'-b) < tol);
    
    if numel(ips) < 3 
        isEffect(ii) = false;
        continue
    end
    
    newid = sub_sortFaceP(tcor(ips,:), a);
    tf_P{ii} = ips(newid);
end

if sum(isEffect) < 4
    tC = [];  tf_P =[];
else
    tC=tC(isEffect,:);
    tf_P = tf_P(isEffect);     
end

end

% sortFace by normal
function newid = sub_sortFaceP(fcors, normal)
tnp= size(fcors,1);
p0 = sum(fcors,1)/tnp;

% cal others relating p0
v0s = fcors - p0;    v0s = v0s./(vecnorm(v0s,2,2));
v01 = v0s(1,:);

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

[vAngle, newid] = sort(vAngle);
end

% get volume
function V = sub_volume(va, vb, vc)
V = vc(3)*(va(1)*vb(2)-va(2)*vb(1))...
    + vc(1)*(va(2)*vb(3)-va(3)*vb(2))...
    + vc(2)*(va(3)*vb(1)-va(1)*vb(3));
end
