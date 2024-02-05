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
function newid = sub_sortFaceP(fcors, n1)
tnp= size(fcors,1);
p0 = sum(fcors,1)/tnp;

% cal others relating p0
vs = fcors - p0;   
n2 = vs(1,:);       n2 = n2/norm(n2);
n3 = [n1(2)*n2(3)-n1(3)*n2(2), n1(3)*n2(1)-n1(1)*n2(3), n1(1)*n2(2)-n1(2)*n2(1)];

ys = vs * n2';
zs = vs * n3';

[~, newid] = sort(atan2(zs, ys));
end
