%{
快速判断点是否在多面体内（张宁 202312）
输入
    ps 待检查的所有点坐标
    C 多面体的C
    tol 容差
输出
    tag 布尔列向量
%}
function tag = Con3_pointIsIn(C, ps, tol)
% tol 容差，默认不输入时为零
if nargin == 2
    tol = 0;
end
tag = all(C(:, 3:5) * ps' < C(:, 2) + tol, 1)';
end
