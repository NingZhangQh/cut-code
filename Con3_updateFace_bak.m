%{
计算多面体的面（张宁 202312）
输入
    tC 凸多面体的tC = [b, A]
    tcor 凸多面体所有的顶点
输出
    tC 凸多面体的tC
%}
function [tC, tf_P] = Con3_updateFace_bak(tC, tcor)
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
function newid = sub_sortFaceP(fcors, n1)
tnp= size(fcors,1);
p0 = sum(fcors,1)/tnp;

% cal others relating p0
vs = fcors - p0;    vs = vs./(vecnorm(vs,2,2));
n2 = vs(1,:);
n3 = [n1(2)*n2(3)-n1(3)*n2(2), n1(3)*n2(1)-n1(1)*n2(3), n1(1)*n2(2)-n1(2)*n2(1)];

ys = vs * n2';
zs = vs * n3';


% angles
vAngle = zeros(tnp,1);
for jj = 2:tnp
    angle = acos(sum(vs(jj,:).*n2));
    % positve volum
    if sub_volume(n2, vs(jj,:), n1) >= 0
        vAngle(jj) = angle; % 1 2
    else
        vAngle(jj) = 2*pi-angle; % 3,4
    end
end
vAngle2 = atan2(zs, ys);

[~, newid] = sort(vAngle);
end

% get volume
function V = sub_volume(va, vb, vc)
V = vc(3)*(va(1)*vb(2)-va(2)*vb(1))...
    + vc(1)*(va(2)*vb(3)-va(3)*vb(2))...
    + vc(2)*(va(3)*vb(1)-va(1)*vb(3));
end
