%{
gap > 0, point is out side the convex body
gap = 0, point is on the convex body
gap < 0, point is inside the convex body
=== n_zhang_qh@163.com  NingZhang===
%}
function gap = Con3_pointGap(C, ps)
gap = max(C(:, 3:5) * ps' - C(:, 2))';
end
