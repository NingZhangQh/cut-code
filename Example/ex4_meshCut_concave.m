%{
Example: generate mesh on a concave block
=== n_zhang_qh@163.com  NingZhang===
%}
clc; clear;
dbstop if error
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

% modify
rng(12)
C = rand_C(1);
cs.add_cut_oneSide(C)

cs.plot_byFace(1)

% cut
ms = CutMeshSysem(cs);
ms.set_mesh(0.2, [0,0,0]);
ms.plot_byFace(2,2);