%{
Example: from algebric representation to gemetric representation
=== n_zhang_qh@163.com  NingZhang===
%}

% Each line is a vertex of the convex body
cor = [0    0    0
    0    0     1
    0    1     0
    0    1     1
    0.2  0    1
    0.2  1    1
    1     0    0
    1     1    0];
C = Con3_updateByV(cor);

b = C(:, 2);
% "N and b matrix"
N = C(:, 3:5)
b = C(:, 2)
      