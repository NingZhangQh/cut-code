%{
get volume of a convex by faces and coordinates
input:
    F:      faces
    cor:   vertexes
=== n_zhang_qh@163.com  NingZhang===
%}
function V = Con3_getVolume(F, cor)
V  = 0;
cor = cor - cor(1,:);
for jj = 1:size(F,1)
    tps = F{jj};
    x1 = cor(tps(1),1);    y1 = cor(tps(1),2);    z1 = cor(tps(1),3);
    for kk = 3: numel(tps)
        x2 = cor(tps(kk-1),1);    y2 = cor(tps(kk-1),2);    z2 = cor(tps(kk-1),3);
        x3 = cor(tps(kk   ),1);    y3 = cor(tps(kk   ),2);    z3 = cor(tps(kk   ),3);
        V = V + x1*(y2*z3-z2*y3) + y1*(z2*x3-x2*z3) + z1*(x2*y3-y2*x3);
    end
end
V = V/6;
end



