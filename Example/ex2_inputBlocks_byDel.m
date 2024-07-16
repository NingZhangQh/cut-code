%{
Example: input regularly arranged blocks first, then delete some
=== n_zhang_qh@163.com  NingZhang===
%}

clc; clear
cs= ConvexSystem(1000); % set capacity to 1000
app = AppPlot();


cubeSize = [1,1,0.5];

% regularly arranged blocks
for ii = 1:10
    x0 = (ii - 1) * cubeSize(1);
    x1 = (ii    ) * cubeSize(1);
    for jj = 1:10
        y0 = (jj - 1) * cubeSize(2);
        y1 = (jj    ) * cubeSize(2);
        for kk = 1:15
            z0 = (kk - 1) * cubeSize(3);
            z1 = (kk    ) * cubeSize(3);
            cs.addConvex_byBox([x0, x1, y0, y1, z0, z1], true);
        end
    end
end

% plot the regularly arranged blocks
cs.plot_byFace(1)

% delete 
box = cs.get_box();
cen = 0.5 * (box(:,[1,3,5]) + box(:,[2,4,6]));

tagDel1 = cen(:,1) > 3 & cen(:,1) < 8 ...
    & cen(:,3) > 2 & cen(:,3) < 5;
tagDel2 = cen(:,2) > 3 & cen(:,2) < 8 ...
    & cen(:,3) > 2;

cs.del_convex(find(tagDel1 | tagDel2))

% show 
app.Set_blockData(cs)


