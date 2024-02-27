%{
Example: cut a hole block by 50 joints
=== n_zhang_qh@163.com  NingZhang===
%}
clc; clear
csTemp= ConvexSystem(1); 
corSlope = [  0         0         0
    0         0    1.0000
    0    1.0000         0
    0    1.0000    1.0000    
    0.2500         0    1.0000
    0.2500    1.0000    1.0000
    1.0000         0         0
    1.0000    1.0000         0];  
corHole = [0.2, 0, 0.2
    0.35, 0, 0.2
    0.35, 0, 0.4
    0.30, 0, 0.43
    0.25, 0, 0.43
    0.2, 0, 0.4
    
    0.2, 1, 0.2
    0.35, 1, 0.2
    0.35, 1, 0.4
    0.30, 1, 0.43
    0.25, 1, 0.43
    0.2, 1, 0.4];

fid = 1;
plot_points3(corSlope, 1, false, true);
plot_points3(corHole, 1, true, true);

data = {[1,7,3,8], [1,2,7,8]
    [1,2,3,4], [1,6,7,12]
    [7,8], [2,3,8,9]
    [7,8], [2,3,8,9]
    [5,6,7,8], [3,9]
    [5,6], [3,4,9,10]
    [5,6], [4,5,10,11]
    [5,6,2,4], [5,6,11,12]}

cs = ConvexSystem();
for ii = 1:size(data,1)
    isNewBlock = (ii == 1);
    cs.addConvex_byV([corSlope(data{ii,1}, :); corHole(data{ii,2}, :)], isNewBlock);
    
    pause(0.2)
    cs.plot_byFace(2)
end
rng(1)
C = rand_C(50);
cs.add_cut_bothSide(C)

app = AppPlot();
app.Set_blockData(cs)
