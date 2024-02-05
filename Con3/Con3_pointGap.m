function gap = Con3_pointGap(C, ps)
% tol 容差，默认不输入时为零
gap = max(C(:, 3:5) * ps' - C(:, 2))';
end
