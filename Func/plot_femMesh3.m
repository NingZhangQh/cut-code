%{
Plot 3D fem mesh
Input
    p_cor: [x,y,z]
    ele_p: Tet4 or Hex8
    fig: the figure to show the plot 
=== n_zhang_qh@163.com  NingZhang===
%}
function h1 = plot_femMesh3(p_cor, ele_p, fig)

np = size(p_cor,1); ne = size(ele_p,1);    nep = size(ele_p,2);

if nep == 8
    cc = [2,3,7,6
        5,8,4,1
        6,5,1,2
        3,4,8,7
        4,3,2,1
        5,6,7,8];
    fs = zeros(ne*6,4);
    for ii = 1:ne
        % ---- the pe
        tps = ele_p(ii,:);
        fs(ii*6-5:ii*6,:) = tps(cc);
    end
elseif nep == 4
    cc = [1,2,3
        2,3,4
        3,4,1
        4,1,2];
    fs = zeros(ne*4,3);
    for ii = 1:ne
        % ---- the pe
        tps = ele_p(ii,:);
        fs(ii*4-3:ii*4,:) = tps(cc);
    end
end

h1=figure (fig); clf;
patch('Faces',fs,'Vertices',p_cor,'FaceColor',	'#4DBEEE','FaceAlpha',0.9);   
axis equal
xlabel('x');  ylabel('y'); zlabel('z');
view(-37.5,30);
end

