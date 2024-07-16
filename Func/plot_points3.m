%{
Plot points to a figure
Input
    cor: [x,y,z]
    fid: figure number
    ishold: hold on    
=== n_zhang_qh@163.com  NingZhang===
%}
function plot_points3(cors, fid, isHold, isText)

figure(fid);  
if isHold
    hold on;
else
    hold off;
end

if nargin == 3
    isText = false;
end

axis equal
x = cors(:, 1);  y = cors(:, 2); z=cors(:,3);
scatter3(x, y, z,'filled');

if isText
    text(x,y,z, num2str([1:numel(x)]'));
end
end