%{
Example: generate mesh on T-shaped bar
=== n_zhang_qh@163.com  NingZhang===
%}
clc; clear
cs= ConvexSystem(2); 
cors = [0,0,0
    0.1,0, 0
    0.1,0.1,0
    0.2,0.2,0
    0.2,0.25,0
    -0.1,0.25,0
    -0.1,0.2,0
    0,0.15,0

    0,0,0.1
    0.1,0, 0.1
    0.1,0.1,0.1
    0.2,0.2,0.1
    0.2,0.25,0.1
    -0.1,0.25,0.1
    -0.1,0.2,0.1
    0,0.15,0.1]*10;
cor1 = cors([1,2,3,8, 9,10,11,16],:);
cor2 = cors([3,4,5,6,7, 11,12,13,14,15],:);


cs.addConvex_byV(cor1, true); 

cs.addConvex_byV(cor2, false); 

% add convex 
ms = CutMeshSysem(cs);
ms.set_mesh(1/8, [0,0,0]);

ms.plot_byFace(2);

