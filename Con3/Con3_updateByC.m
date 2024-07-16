%{
Generate vertexes by tC
input:
    tC: [0, b, N]
note:
    tC is updated to remove redundant faces
=== n_zhang_qh@163.com  NingZhang===
%}
function [tC, tcors] = Con3_updateByC(tC)
tC  = uniquetol(tC, 1e-6, 'ByRows', true);
tnf = size(tC,1);

% 标记多余的面
tf_used = false(tnf,1);

% point cap
tcors = zeros(tnf*3,3);   tnp = 0;
Tol = 1e-6;

A = tC(:, 3:5);    b = tC(:, 2);
for ii = 1:tnf-2
    for jj = ii+1:tnf-1
        for kk = jj+1:tnf
            
            detA = A(ii,1) * ( A(jj,2)*A(kk,3) - A(jj,3)*A(kk,2))...
                + A(ii,2) * ( A(jj,3)*A(kk,1) - A(jj,1)*A(kk,3))...
                + A(ii,3) * ( A(jj,1)*A(kk,2) - A(jj,2)*A(kk,1));
         
            if detA*detA < Tol
                continue
            end
            ipf = [ii, jj, kk];
            icor =  A(ipf, :)\b(ipf);
            
            % check if out side
            if any(A * icor - b > Tol)
                continue
            else
                tcors(tnp+1,:) = icor;
                tnp = tnp + 1;
                
                tf_used(ii) = true;   tf_used(jj) = true;  tf_used(kk) = true;
            end
        end % kk
    end % jj
end % ii

tcors(tnp+1:end,:)= [];

% unique
tcors = uniquetol(tcors, 1e-6, 'ByRows',true);
if size(tcors,1) < 4
    tC = [];  tcors = [];
else
    tC    = tC(tf_used,:);
end
end

