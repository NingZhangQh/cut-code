%{
删除tC中多余的面，并生成所有顶点（张宁 202312）
输入
    tC 原始的tC = [b, A]
输出
    tC 删除多余的面后的tC
    tcor 多面体所有的顶点
%}
function [tC, tcors] = Con3_updateByC(tC)
% warning('off','MATLAB:rankDeficientMatrix');
tC  = uniquetol(tC, 1e-6, 'ByRows', true);
tnf = size(tC,1);

% 标记多余的面
tf_used = false(tnf,1);

% point cap
tcors = zeros(tnf*3,3);   tnp = 0;
%tp_f   = cell(tnf*tnf,1);
Tol = 1e-6;

for ii = 1:tnf
    for jj = ii+1:tnf
        for kk = jj+1:tnf
            ipf = [ii, jj, kk];
            iA  = tC(ipf, 3:5); 

            if abs(det(iA)) < Tol
                continue
            end
            ib = tC(ipf,2); 

            icor = iA\ib;
            
            % check if out side
            if any(tC(:, 3:5) * icor > tC(:, 2) + Tol)
                continue
            else
                tcors(tnp+1,:) = icor;
                tnp = tnp + 1;
                
                tf_used(ii) = true;   tf_used(jj) = true;  tf_used(kk) = true;
            end
        end % kk
    end % jj
end % ii

%tp_f(tnp+1:end)    = [];
tcors(tnp+1:end,:)= [];

% unique
tcors = uniquetol(tcors, 1e-6, 'ByRows',true);
tC     = tC(tf_used,:);

% warning('on','MATLAB:rankDeficientMatrix');
end

