%{
Example: Input regular_polyhedron by coordinates (with 4, 6, 8, 12, 20 faces)
=== n_zhang_qh@163.com  NingZhang===
%}

clc; clear
cs= ConvexSystem(5); % set capacity to 4 convex body
app = AppPlot();

cs.addConvex_byV(regular_polyhedron(4) + [0, 0, 0], true)
cs.addConvex_byV(regular_polyhedron(8) + [2, 0, 0], true)
cs.addConvex_byV(regular_polyhedron(12) + [0, 2, 0], true)
cs.addConvex_byV(regular_polyhedron(20) + [2, 2, 0], true)

cs.plot_byFace(2)

app.Set_blockData(cs)


function v = regular_polyhedron(nf)

if nf == 4
    v =  [1, 1, 1;
        1, -1, -1;
        -1, 1, -1;
        -1, -1, 1]/sqrt(8);
elseif nf == 6
    v = [1, 1, 1;
        1, 1, -1;
        1, -1, 1;
        1, -1, -1;
        -1, 1, 1;
        -1, 1, -1;
        -1, -1, 1;
        -1, -1, -1]/2;
elseif nf == 8
    v = [0, 0, 1;
        1, 0, 0;
        0, 1, 0;
        -1, 0, 0;
        0, -1, 0;
        0, 0, -1]/sqrt(2);
elseif nf == 12
    phi = (1 + sqrt(5)) / 2;
    v = [...
        1, 1, 1;
        1, 1, -1;
        1, -1, 1;
        1, -1, -1;
        -1, 1, 1;
        -1, 1, -1;
        -1, -1, 1;
        -1, -1, -1;
        0, phi, 1/phi;
        0, phi, -1/phi;
        0, -phi, 1/phi;
        0, -phi, -1/phi;
        1/phi, 0, phi;
        1/phi, 0, -phi;
        -1/phi, 0, phi;
        -1/phi, 0, -phi;
        phi, 1/phi, 0;
        phi, -1/phi, 0;
        -phi, 1/phi, 0;
        -phi, -1/phi, 0]/2;
elseif nf == 20
    phi = (1 + sqrt(5)) / 2;
    v= [0, 1, phi;
        0, -1, phi;
        0, 1, -phi;
        0, -1, -phi;
        1, phi, 0;
        -1, phi, 0;
        1, -phi, 0;
        -1, -phi, 0;
        phi, 0, 1;
        -phi, 0, 1;
        phi, 0, -1;
        -phi, 0, -1
        ] / sqrt(1 + phi^2);
end
end
