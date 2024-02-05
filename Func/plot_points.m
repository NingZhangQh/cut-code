function Plot_points(cors, fid, isHold)
% cors 坐标
% fid 绘图编号
% isHold，是否打开 hold on
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