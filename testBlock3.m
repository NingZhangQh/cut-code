dbstop if error
clc; clear
test = 1;
profile on



name = 'cut'

C_slope = [0, 0, -1, 0, 0
    0, 8, 2/sqrt(5), 0, 1/sqrt(5)
    0, 0, 0,-1, 0
    0, 8, 0, 2/sqrt(5), 1/sqrt(5)
    0,-5, 0, 0,-1
    0,10, 0, 0, 1];

switch name
    case 'ini'
        % by box
        cs= ConvexSystem();
        cs.set_capacity(3)
        cs.addConvex_byBox([0,10, 0, 10, 0,6])
      
        cs.plot_byFace(1);
        
       % tag = bk.check_insideConvex([0,0,0; 1,1,1], 0.0, 1);
        
        cs= ConvexSystem();
        
        tbk =  Block3(C_slope);
        cor = tbk.cor;
        cs.addConvex_byC(C_slope)
        
        cs.plot_byFace(1);

        % cor
        cs.clear();
        cs.addConvex_byV(cor)
        cs.plot_byFace(1);
        
        tbk = Block3([], tbk.cor);
        

        % C cor and fn
        cs.clear();
        cs.addConvex(tbk.C, tbk.cor, []);
        
        
        cs.plot_byFace(1);
        cs.addConvex_byBox([0,10,0,10,0,5])
        cs.plot_byFace(1);
        
        
        
        % concave
        cc=1
        
    case 'cut'
        cor = [  0         0         0
            0         0    1.0000
            0    1.0000         0
            0    1.0000    1.0000
            0.2500         0    1.0000
            0.2500    1.0000    1.0000
            1.0000         0         0
            1.0000    1.0000         0];
        cs = ConvexSystem();        
        cs.addConvex_byV(cor, true)
        cs.addConvex_byBox([0,2, 0,2, -1,0], false)
        cs.plot_byFace(1)
        
        if 0
            
            
            mesh = CutMeshSysem(cs)
            mesh.plot_byFace(2)
        else
            box = cs.get_box;
            %bk.plot_byFace(1)
            C = rand(2, 5)-0.5;  C(:,1) = 0;
            C = C./vecnorm(C(:,3:5), 2, 2);
            C=[[0,0.238566972682340,0.676889501590035,0.166690194125286,0.716962329428589;0,0.701503271724398,0.641836126244903,0.134311409057442,-0.754987968410054]]
            %         C = [0,-0.0328018215488088,-0.555080544620163,-0.819465042027048,-0.142697701031906;0,-1.00595484863073,0.0892020608259880,0.821823748998777,0.562715485770555;0,0.535745062436736,-0.776260103927379,-0.396071344438217,0.490456665940589;0,-2.56626543744237,-0.608386609563895,0.665244094642520,-0.432800217013119;0,-0.327244068944367,-0.627929004094515,0.738002513642400,0.247098068940997];
            %         C= [0,-0.630758572887596,-0.835925525071861,0.218156361810617,-0.503623190823148]
            %C(:,1) = 0;   C = C(:,3:5)/norm(C(:,3:5));
            tic
            cs.add_cut_bothSide(C)
            cs.plot_byFace(1)
            
            
            app = AppPlot();
            app.Set_blockData(cs)
            
        end
        cc.bks = cs;
        cs.plot_byFace(1)
        
        toc
        bkbak = ConvexSystem_bak;
       
        bkbak.addConvex_byV(cor);
         tic
        bkbak.add_cut(C)
        bkbak.plot_byFace(2)
        toc
        profile viewer
        return
        mbk = Block3(mbox);
        mbk.Plot(1,0,1);
        bk1 = cs.cal_interWithBox(mbox, 1e-6);
        bk1.Plot(2,0);

        % cut mesh
        tic
        [mp_cor, e_mp, e_pb, e_isFE] = cs.cut3DIni([0.6,0.6,0.6], [0,0,0], 1);
        toc
        Block3.PlotBks(e_pb, 1,0);
    case 'cutCurve'
        % cut mesh with hole
        cs = Block3([0,10,0,10,0,6]);
        cirs= [1.1, 3, 3,2,3
            1.1,  3, 5,8,2];
        cs.C = [cs.C;cirs];   cs.con = cs.con + [0,2,0,0];

        tic
        [mp_cor, e_mp, e_pb, e_isFE] = cs.cut3DIni([0.8,0.8,1], [0,0,0], 1);
        toc
        Block3.PlotBks(e_pb, 1,0);
    case 'cutWithIniMesh'
        [p_cor, e_p] = Mesh.meshHex(10,10,10, 21,21,21, 1);
        cs = Block3.ComplexBk(Block3(C_slope), Block3([0,10,0,10,0,5]));

        [mp_cor, e_mp, e_pb, e_isFE] =  cs.cutMesh(p_cor, e_p, [],2, 4);
    
end

% test Cut
Bk3_genMeshCut(cs, nmmh,[1,1,1], [0,0,0])

nmmh.plotMesh3D(nmmh,[], 1, 0)