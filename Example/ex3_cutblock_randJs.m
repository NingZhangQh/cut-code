%{
Example: cut a convex body by 100 joints
=== n_zhang_qh@163.com  NingZhang===
%}
clc; clear
cs= ConvexSystem(2); % set capacity to 2 convex body

% add convex 1
cor = [  0         0         0
    0         0    1.0000
    0    1.0000         0
    0    1.0000    1.0000
    0.2500         0    1.0000
    0.2500    1.0000    1.0000
    1.0000         0         0
    1.0000    1.0000         0];       
cs.addConvex_byV(cor, true); 

% add convex 
cs.addConvex_byBox([0,2, 0,2, -1,0], false) %second part   

% the joint
rng(1)
C = rand_C(100);

% the volume of uncut block
V0 = cs.get_volume_byBlock();

% cutting
tic
cs.add_cut_bothSide(C);
toc

% the volumes after cutting
Vs = cs.get_volume_byBlock();
[minV, minID] = min(Vs);

app = AppPlot();
app.Set_blockData(cs)
