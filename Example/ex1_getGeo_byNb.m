%{
Example: from gemetric representation to algebric representation
=== n_zhang_qh@163.com  NingZhang===
%}


% load C from ex_get_geo_by_Nd
% C = [0, b, N]
ex1_getNb_byCor;
corBak = cor;

% C is output again, because we check and remove repeat rows here
[C, cor] = Con3_updateByC(C);

% C is output again, because we remove rebundant rows here
[C, F]  = Con3_updateFace(C, cor);

% out put
disp("the reference")
corBak
disp("the obtained (The order may not be consistent)")
cor
disp("the obtained faces")
F

      