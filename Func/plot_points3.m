%{
Plot points to a figure
Input
    cor: [x,y,z]
    fid: figure number
    ishold: hold on    
=== n_zhang_qh@163.com  NingZhang===
%}
function plot_points3(cors, fid, isHold)

figure(fid);  
if isHold
    hold on;
else
    hold off;
end
axis equal
x = cors(:, 1);  y = cors(:, 2); z=cors(:,3);
plot3(x, y, z,".");
end