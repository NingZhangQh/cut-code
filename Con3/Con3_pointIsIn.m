%{
a vecorized checking on whether points are inside the convex body
input
    C: [0, b, N]
    ps: points [xs, ys, zs]
    tol: tollerance (optional)
=== n_zhang_qh@163.com  NingZhang===
%}
function tag = Con3_pointIsIn(C, ps, tol)
if nargin == 2
    tol = 0;
end
tag = all(C(:, 3:5) * ps' < C(:, 2) + tol, 1)';
end
