%{
Example: Input a four-layer pyramid consisting of 3 blocks
namely, 1-2 is a block, 3 is a block 4 is a block
(Each layer takes one input method)
=== n_zhang_qh@163.com  NingZhang===
%}
clc; clear
cs= ConvexSystem(4); % set capacity to 4 convex body
app = AppPlot();

% layer 1 
cs.addConvex_byBox([-4,4, -4,4, 0,1], true) % new block

% layer 2 (equal to cs.addConvex_byBox([-3,3, -3,3, 1,2], false))
cor = [    -3    -3     1
     3    -3     1
     3     3     1
    -3     3     1
    -3    -3     2
     3    -3     2
     3     3     2
    -3     3     2];
cs.addConvex_byV(cor, false); % not a new block

% layer 3 (equal to cs.addConvex_byBox([-2,2, -2,2, 2,3], true))
C = [     0     2    -1     0     0
     0     2     1     0     0
     0     2     0    -1     0
     0     2     0     1     0
     0    -2     0     0    -1
     0     3     0     0     1];  % 0 b N
cs.addConvex_byC(C, true); % new block

% layer 4 (equal to cs.addConvex_byBox([-1,1, -1,1, 3,4], true))
C = [      0     1    -1     0     0
     0     1     1     0     0
     0     1     0    -1     0
     0     1     0     1     0
     0    -3     0     0    -1
     0     4     0     0     1];
 cor = [    -1    -1     3
     1    -1     3
     1     1     3
    -1     1     3
    -1    -1     4
     1    -1     4
     1     1     4
    -1     1     4];
F = {[4,1,5,8]
    [2,3,7,6]
    [1,2,6,5]
    [3,4,8,7]
    [4,3,2,1]
    [5,6,7,8]};
cs.addConvex(C, cor, F); % new block

% get calculated properties (optional)
con_V = cs.get_volume()
con_box = cs.get_box()
block_ID = cs.get_blockID()

% App
app.Set_blockData(cs);