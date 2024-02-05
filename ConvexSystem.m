classdef ConvexSystem < handle % geoInfovex3d
    properties
        count = 0    % count of convex
        tag                % each convex: belong to block
        
        C                 % each convex: {b and A}
        F                  % each covnex: {faces}
        Cor               % each covnex: {vertexes} Title
    end
    
    methods
        function obj = ConvexSystem(cap)
            %{
            initialize the block system
            "cap" should be an integer
            %}
            if nargin == 0
                cap = 1;
            end
            obj.tag  = false(cap, 1);
            obj.C = cell(cap, 1);
            obj.F = cell(cap, 1);
            obj.Cor = cell(cap, 1);
        end
        
        function box = get_box(obj)
            box = zeros(obj.count, 6);
            for ii = 1:size(box,1)
                c = minmax(obj.Cor{ii}'); 
                box(ii, :) = c(:);                
            end
            box = box(:, [1,4,2,5,3,6]);            
        end
        
        function V = get_volume(obj)
            V = zeros(obj.count, 1);
            
            for ii = 1:obj.count
                % ini
                iDet = 0;
                icor = obj.Cor{ii};    iF = obj.F{ii};
                
                % get
                icor = icor - icor(1,:);
                for jj = 1:size(iF,1)
                    tps = iF{jj};
                    x1 = icor(tps(1),1);    y1 = icor(tps(1),2);    z1 = icor(tps(1),3);
                    for kk = 3: numel(tps)
                        x2 = icor(tps(kk-1),1);    y2 = icor(tps(kk-1),2);    z2 = icor(tps(kk-1),3);
                        x3 = icor(tps(kk   ),1);    y3 = icor(tps(kk   ),2);    z3 = icor(tps(kk   ),3);
                        iDet = iDet + x1*(y2*z3-z2*y3) + y1*(z2*x3-x2*z3) + z1*(x2*y3-y2*x3);
                    end
                end
                V(ii) = iDet/6;
            end
        end
        
        function blockID = get_blockID(obj)
            %{
            get "iniCon" and "nCon" of each block
            %}
            iniCon = find(obj.tag == 1) - 1;
            nCon   = [iniCon(2:end); obj.count] - iniCon;
            blockID = [iniCon, nCon];
        end
        
        function set_capacity(obj, cap)
            %{
            set capacity of the convex
            "cap" should be an integer
            %}
            if cap > obj.count
                obj.tag(cap, 1) = false;
                obj.C{cap, 1} = [];
                obj.F{cap, 1} = [];
                obj.Cor{cap, 1} = [];
            else
                obj.tag(obj.count+1: end)  = [];
                obj.C(obj.count+1: end) = [];
                obj.F(obj.count+1: end) = [];
                obj.Cor(obj.count+1: end) = [];
                disp("warning, set_capacity takes convex num  (the input value is too small) ")
            end
        end
        
        function clear(obj)
            obj.count = 0;
            obj.tag(:)  = false;
            obj.C(:) = {[]};
            obj.F(:) = {[]};
            obj.Cor(:) = {[]};
        end
        
        function del_convex(obj, iConvex)
            obj.count = obj.count - numel(iConvex);
            obj.tag(iConvex)  = [];
            obj.C(iConvex) = [];
            obj.F(iConvex) = [];
            obj.Cor(iConvex) = [];
        end
        

        function addConvex_byBox(obj, box, isNewBlock)
            %{
            add a convex by box
            "box" [xmin xmax ymin ymax zmin zmax]
            %}
            if nargin == 2
                isNewBlock = true;
            end
            
            icon = obj.count + 1;
            
            obj.count = icon;
            obj.C{icon,1} = [0,-box(1), -1, 0, 0
                0, box(2),  1, 0, 0
                0,-box(3),  0,-1, 0
                0, box(4),  0, 1, 0
                0,-box(5),  0, 0,-1
                0, box(6),  0, 0, 1];
            obj.Cor{icon,1} = box([1,3,5; 2,3,5; 2,4,5; 1,4,5
                1,3,6; 2,3,6; 2,4,6; 1,4,6]);
            obj.F{icon,1} = {[4,1,5,8]
                [2,3,7,6]
                [1,2,6,5]
                [3,4,8,7]
                [4,3,2,1]
                [5,6,7,8]};
            
            obj.tag(icon,1) = isNewBlock;
        end
        
        function plot_byFace(obj, fid)
            ncon = obj.count;
            
            % nf,  fnpMax,   con_p0
            con_p0  = zeros(ncon, 1);
            fnpMax = 0;     nf =0;      pid = 0;
            
            for ii = 1:ncon
                tF = obj.F{ii};
                for jj =1:size(tF,1)
                    cc = size(tF{jj},2);
                    if cc > fnpMax
                        fnpMax = cc ;
                    end
                end
                nf = nf + size(tF,1);
                
                % con_np
                con_p0(ii) = pid;
                pid           = pid + size(obj.Cor{ii},1);
            end
            
            % parepare faces and cors
            cors = cat(1, obj.Cor{:});
            fs = nan(nf, fnpMax);   iface = 0;
            for ii = 1:ncon
                tF = obj.F{ii};
                for jj =1:size(tF,1)
                    fs(iface+1,1: size(tF{jj},2)) = tF{jj} + con_p0(ii);
                    
                    % next
                    iface = iface + 1;
                end
            end
            
            
            % plot
            figure(fid);  clf;
            axis equal; view(-37.5,30); xlabel('X');  ylabel('Y'); zlabel('Z');
            patch('Faces',fs,'Vertices',cors,'FaceColor','#4DBEEE','FaceAlpha',0.8);
        end
        
        function addConvex(obj, tC, tcor, tF, isNewBlock)
            if nargin == 4
                isNewBlock = true;
            end
            
            if isempty(tF)
                [tC, tF] = Con3_updateFace(tC, tcor);
            end
            
            if isempty(tC)  % row of C less than 4
                disp("Not added. Please check C")
            else
                icon = obj.count + 1;
                
                obj.count = icon;
                obj.C{icon,1}= tC;     obj.F{icon,1} = tF;   obj.Cor{icon,1} = tcor;
                obj.tag(icon,1) = isNewBlock;
            end
        end
        
        function isAdded = addConvex_byC(obj, tC, isNewBlock)
            %{
            add a convex by C
            "C" [0, b, ax, ay, az]
            %}
            if nargin == 2
                isNewBlock = true;
            end
            
            [tC, tcor] = Con3_updateByC(tC);
            %hold on ;plot3(tcor(:,1), tcor(:,2), tcor(:,3),'*')
            isAdded = false;
            if isempty(tcor) % no cor
                disp("Not added. Please check C")
            else
                %tCbak = tC
                [tC, tF] = Con3_updateFace(tC, tcor);
                if isempty(tC)  % row of C less than 4
                    disp("Not added. Please check C")                    
                else
                    icon = obj.count + 1;
                    
                    obj.count = icon;
                    obj.C{icon,1}= tC;     obj.F{icon,1} = tF;   obj.Cor{icon,1} = tcor;
                    obj.tag(icon, 1) = isNewBlock;
                    
                    isAdded = true;
                end
            end
        end
        
        function addConvex_byV(obj, tcor, isNewBlock)
            if nargin == 2
                isNewBlock = true;
            end
            
            [tC, tcor] = Con3_updateByV(tcor);
            [tC, tF] = Con3_updateFace(tC, tcor);
            
            if isempty(tC)  % row of C less than 4
                disp("Not added. Please check cor")
            else
                icon = obj.count + 1;
                
                obj.count = icon;
                obj.C{icon,1}= tC;     obj.F{icon,1} = tF;   obj.Cor{icon,1} = tcor;
                obj.tag(icon,1) = isNewBlock;
            end
        end
        
     
        
        function add_cut_bothSide(obj, cutC, cutBlocks)      
            nb = sum(obj.tag);
            if nargin < 3
                cutBlocks = 1: nb;
            end
            tol = 1e-6;
            
            % ncut
            nCut = size(cutC, 1);
            
            % bTag
            bID = obj.get_blockID();    
            bID((nb+1) * (nCut+1), 1) = 0;
            
            % -1 to delete; 0 to remain, 1 to cut  
            bTag = zeros((nb+1) * (nCut+1), 1);    
            bTag(cutBlocks) = 1;
            
            for ii = 1: size(cutC, 1)
                iC = cutC(ii, :);   iA = cutC(ii,3:5);    ib = cutC(ii,2);
                ncon = obj.count;
             
                % set capacity
                if size(obj.tag, 1) < ncon * 2
                    obj.set_capacity(ncon * 2+1);
                end
                
                % the left and r con     
                for jj = 1: nb  
                    % if is remain
                    if bTag(jj) ~= 1
                        continue
                    end
                    
                    iniCon = bID(jj, 1);    nConInB = bID(jj, 2);
                    
                    % -1 N, 0 cut; 1 P
                    side = zeros(nConInB, 1);
                    for kk = 1: nConInB
                        kcon = iniCon + kk;
                        dis = iA* obj.Cor{kcon}' - ib;
                        if all(dis < tol)
                            side(kk) = 1;
                        elseif all(dis > -tol)
                            side(kk) = -1;
                        end
                    end
                    
                    % cut
                    if all(side == 1) || all(side == -1)
                        % remain
                    else  
                        % add left
                        for kk = 1:numel(side)
                            if side(kk) == 1
                                kcon = iniCon + kk;
                                obj.addConvex(obj.C{kcon}, obj.Cor{kcon}, obj.F{kcon}, false);
                                disp(1)
                            end
                        end
                        
                        for kk = 1:numel(side)
                            if side(kk) == 0
                                kcon = iniCon + kk;
                                obj.addConvex_byC([obj.C{kcon}; iC], false);
                                disp(21)
                            end
                        end
                        
                        
                        obj.tag(ncon + 1) = true;  % first
                        bID(nb+1, :)   = [ncon, obj.count - ncon];
                        ncon = obj.count;
                        
                        % add right
                        for kk = 1:numel(side)
                            if side(kk) == 0
                                kcon = iniCon + kk;
                                obj.addConvex_byC([obj.C{kcon}; -iC], false);
                                disp(22)
                            end
                        end
                        
                        for kk = 1:numel(side)
                            if side(kk) == -1
                                kcon = iniCon + kk;
                                obj.addConvex(obj.C{kcon}, obj.Cor{kcon}, obj.F{kcon}, false);
                                disp(3)
                            end
                        end
                        
                        obj.tag(ncon + 1) = true;  % first
                        bID(nb+2, :)   = [ncon, obj.count - ncon];
                        ncon = obj.count;
                        
                        % set block tag
                        bTag(jj) = -1;    bTag(nb+1) = 1;      bTag(nb+2) = 1;
                        nb = nb + 2;
                    end
                end
            end
            
            % del
            conDel = false(ncon, 1);
            for jj = 1: nb
                if bTag(jj) == -1
                    conDel(bID(jj,1)+1:bID(jj,1)+bID(jj,2)) = true;
                end
            end
            obj.del_convex(find(conDel));
        end
    end    
end
