%{
Generate random C
=== n_zhang_qh@163.com  NingZhang===
%}
function C = rand_C(n)
C = rand(n, 5)-0.5;  C(:,1) = 0;
C = C./vecnorm(C(:,3:5), 2, 2);
end

