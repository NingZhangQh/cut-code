%{
Example: cut a hole block by 50 joints
=== n_zhang_qh@163.com  NingZhang===
%}
clc; clear
cs= ConvexSystem(2); 
cor = [2     2     0
    0.5    2      0
    0.5    0.5    0
    2      0.5    0
    2      2      1
    1.2    2      1
    1.2    1.2    1
    2      1.2    1];       
cs.addConvex_byV(cor, true); 

% add convex 
cs.addConvex_byBox([0,2, 0,2, -0.5,0], false) %second part   


cs.plot_byFace(2)

% joint information

j_strike = [200, 100, 20]/180*pi;
j_dip = [70, 40, 90]/180*pi;
j_spacing = [0.15, 0.2,0.2];
p0 = [0.5,0.5,0.5]; % a initial point
for ii = 1:numel(j_spacing)
    % data
    strike = j_strike(ii); 
    dip = j_dip(ii);
    spacing = j_spacing(ii);

    % initial joint
    jn = [-sin(strike)*sin(dip), cos(strike)*sin(dip), cos(dip)];
    b0 = jn * p0';
    cs.add_cut_bothSide([0, b0, jn]);
    count = cs.count;

    % add left
    b = b0;
    while 1
        b = b + spacing;
        cs.add_cut_bothSide([0, b, jn]);
        
        count0 = count;  count = cs.count;
        if count == count0
            break
        end
    end

    b = b0;
    while 1
        b = b - spacing;
        cs.add_cut_bothSide([0, b, jn]);
        
        count0 = count;  count = cs.count;
        if count == count0
            break
        end
    end
    
end

app = AppPlot();
app.Set_blockData(cs)


