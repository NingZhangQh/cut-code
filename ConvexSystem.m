%{
A class to deal with block system
=== n_zhang_qh@163.com  NingZhang===
%}
classdef ConvexSystem < handle % geoInfovex3d
    properties
        count = 0    % count of convex bodies
        tag                % each convex: belong to block
        
        C                 % each convex: {b and A}
        F                  % each covnex: {faces}
        Cor               % each covnex: {vertexes} 
    end
    
    methods
        %{
            initialize the block system
            "cap" should be an integer
        %}
        function obj = ConvexSystem(cap)
            
            if nargin == 0
                cap = 1;
            end
            obj.tag  = false(cap, 1);
            obj.C = cell(cap, 1);
            obj.F = cell(cap, 1);
            obj.Cor = cell(cap, 1);
        end
        
        %{
            set capacity for efficient computation
            "cap" should be an integer
        %}
        function set_capacity(obj, cap)
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
        
        %{
            clear convex bodies
        %}
        function clear(obj)
            obj.count = 0;
            obj.tag(:)  = false;
            obj.C(:) = {[]};
            obj.F(:) = {[]};
            obj.Cor(:) = {[]};
        end
        
        %{
            del convex bodies
        %}
        function del_convex(obj, iConvex)
            obj.count = obj.count - numel(iConvex);
            obj.tag(iConvex)  = [];
            obj.C(iConvex) = [];
            obj.F(iConvex) = [];
            obj.Cor(iConvex) = [];
        end

        
        %% methods for add convex
        
        %{
            add a convex by box
            "box" [xmin xmax ymin ymax zmin zmax]
        %}
        function addConvex_byBox(obj, box, isNewBlock)
            if nargin == 2
                isNewBlock = true;
            end
            
            icon = obj.count + 1;
            if obj.count  == numel(obj.tag)
                obj.set_capacity(obj.count * 2);
            end
            
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
        
        %{
             add a convex by all properties
        %}
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
                if obj.count  == numel(obj.tag)
                    obj.set_capacity(obj.count * 2);
                end
                
                obj.count = icon;
                obj.C{icon,1}= tC;     obj.F{icon,1} = tF;   obj.Cor{icon,1} = tcor;
                obj.tag(icon,1) = isNewBlock;
            end
        end
        
        %{
            add a convex by C
            "C" [0, b, nx, ny, nz]
        %}
        function isAdded = addConvex_byC(obj, tC, isNewBlock)
            if nargin == 2
                isNewBlock = true;
            end
            
            [tC, tcor] = Con3_updateByC(tC);
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
                    if obj.count  == numel(obj.tag)
                        obj.set_capacity(obj.count * 2);
                    end
                    
                    obj.count = icon;
                    obj.C{icon,1}= tC;     obj.F{icon,1} = tF;   obj.Cor{icon,1} = tcor;
                    obj.tag(icon, 1) = isNewBlock;
                    
                    isAdded = true;
                end
            end
        end
        
        %{
            add a convex by Vertexes
            "V" [x, y, z]
        %}
        function isAdded = addConvex_byV(obj, tcor, isNewBlock)
            if nargin == 2
                isNewBlock = true;
            end
            
            [tC, tcor] = Con3_updateByV(tcor);
            [tC, tF] = Con3_updateFace(tC, tcor);
            
            isAdded = true;
            if isempty(tC)  % row of C less than 4
                disp("Not added. Please check cor")               
                isAdded = false;
            else
                icon = obj.count + 1;
                if obj.count  == numel(obj.tag)
                    obj.set_capacity(obj.count * 2);
                end
                
                obj.count = icon;
                obj.C{icon,1}= tC;     obj.F{icon,1} = tF;   obj.Cor{icon,1} = tcor;
                obj.tag(icon,1) = isNewBlock;
            end
        end
        
        %% methods for cutting
        %{
            a specific cut, it remains only one side of each joint
        %}
        function add_cut_oneSide(obj, cutC, cutBlocks)
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
            bFlag = zeros((nb+1) * (nCut+1), 1);    
            bFlag(cutBlocks) = 1;
            
            for ii = 1: size(cutC, 1)
                iC = cutC(ii, :);   iA = cutC(ii,3:5);    ib = cutC(ii,2);
                ncon = obj.count;
             
              
                % the left and r con     
                for jj = 1: nb  
                    % if is remain
                    if bFlag(jj) ~= 1
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
                    if all(side == 1) 
                        % remain
                    elseif all(side == -1)
                        % delete
                        bFlag(jj) = -1;
                    else  
                        % add left
                        for kk = 1:numel(side)
                            if side(kk) == 1
                                kcon = iniCon + kk;
                                obj.addConvex(obj.C{kcon}, obj.Cor{kcon}, obj.F{kcon}, false);
                            end
                        end
                        
                        for kk = 1:numel(side)
                            if side(kk) == 0
                                kcon = iniCon + kk;
                                obj.addConvex_byC([obj.C{kcon}; iC], false);
                            end
                        end
                        obj.tag(ncon + 1) = true;  % first
                        bID(nb+1, :)   = [ncon, obj.count - ncon];
                        ncon = obj.count;
                        
                        % set block tag
                        bFlag(jj) = -1;    bFlag(nb+1) = 1;     
                        nb = nb + 1;
                    end
                end
            end
            
            % del
            conDel = false(ncon, 1);
            for jj = 1: nb
                if bFlag(jj) == -1
                    conDel(bID(jj,1)+1:bID(jj,1)+bID(jj,2)) = true;
                end
            end
            obj.del_convex(find(conDel));
        end
        
        %{
            regular cut (remain both sides of each joint)
        %}
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
                            side(kk) = 1; % remain
                        elseif all(dis > -tol)
                            side(kk) = -1; % delete
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
                            end
                        end
                        
                        for kk = 1:numel(side)
                            if side(kk) == 0
                                kcon = iniCon + kk;
                                obj.addConvex_byC([obj.C{kcon}; iC], false);
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
                            end
                        end
                        
                        for kk = 1:numel(side)
                            if side(kk) == -1
                                kcon = iniCon + kk;
                                obj.addConvex(obj.C{kcon}, obj.Cor{kcon}, obj.F{kcon}, false);
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
        
        %% other methods
        
        %{
            get box of each convex
        %}
        function box = get_box(obj)
            box = zeros(obj.count, 6);
            for ii = 1:size(box,1)
                c = minmax(obj.Cor{ii}'); 
                box(ii, :) = c(:);                
            end
            box = box(:, [1,4,2,5,3,6]);            
        end
        
        % get "volume" of each block
        function bV = get_volume_byBlock(obj)
            bID = obj.get_blockID();
            Vs   = obj.get_volume();
            
            nb = size(bID,1);
            bV = zeros(nb,1);
            for ii = 1:nb
                for jj = 1:bID(ii,2)
                    bV(ii) = bV(ii) + Vs(bID(ii,1) + jj);
                end
            end
        end
        
        %{
            get volume of each convex
        %}
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
        
        %{
            get convex range of each block
        %}
        function blockID = get_blockID(obj)
            iniCon = find(obj.tag == 1) - 1;
            nCon   = [iniCon(2:end); obj.count] - iniCon;
            blockID = [iniCon, nCon];
        end
        
        %{
            prepare data for plot 
        %}       
        function [cors, fs, fcolor] = get_plotPatch(obj, icons)
            
            ncon = obj.count;
            if nargin == 1
                icons = 1:ncon;
            end
            
            fnpMax = 0;     
            con_nf = zeros(ncon, 1);
            for ii = icons
                tF = obj.F{ii};  tnf = size(tF,1);
                for jj =1:tnf
                    cc = size(tF{jj},2);
                    if cc > fnpMax
                        fnpMax = cc ;
                    end
                end
                con_nf(ii) = tnf;
            end
            nf = sum(con_nf);

            if nargin == 1
                fcolor = zeros(nf,1);
                bid = obj.get_blockID();  nb = size(bid,1);
                rng(1)
                bcolor = rand(nb, 1);
                
                bf0 = 0;
                for ii = 1: size(bid,1)
                    bnf = sum(con_nf(bid(ii,1) + 1: bid(ii,1)+bid(ii,2)));
                    
                    fcolor(bf0+1 : bf0+bnf, :) = repmat(bcolor(ii,:), bnf, 1);
                    bf0 = bf0 + bnf;
                end
            else
                fcolor = "#4DBEEE";
            end
            
            % set fs
            fs = nan(nf, fnpMax);   iface = 0;   p0 = 0;
            for ii = icons
                tF = obj.F{ii};   
                for jj =1:size(tF,1)
                    fs(iface+1,1: size(tF{jj},2)) = tF{jj} + p0;
                    
                    % next
                    iface = iface + 1;
                end
                p0 = p0 + size(obj.Cor{ii},1);
            end
            
            % parepare faces and cors
            cors = cat(1, obj.Cor{icons});
        end
        
        %{
             plot data
        %}   
        function plot_byFace(obj, fid, isRandColor)
            [cors, fs, fcolor] = obj.get_plotPatch();
            if nargin == 2
                isRandColor = true;
            end
            
            % plot
            figure(fid);  clf;
            axis equal; view(-37.5,30); xlabel('X');  ylabel('Y'); zlabel('Z');
            if isRandColor
                patch('Faces',fs,'Vertices',cors,'FaceVertexCData',fcolor,'FaceColor','flat','FaceAlpha',0.8, 'linewidth',1);
            else
                patch('Faces',fs,'Vertices',cors,'FaceColor','#4DBEEE','FaceAlpha',0.8, 'linewidth',1);
            end
         end
        
        %{
             plot single convex with text
        %}   
        function show_singleConvex(obj, id, fid, ishold)
            if nargin == 3
                ishold = true;
            end
           
             % plot
            figure(fid);  
            if ishold 
                hold on;
            else
                hold off;
            end
            [cors, fs] = obj.get_plotPatch(id);
            plot_points3(cors, fid, true, true);
            
            axis equal; view(-37.5,30); xlabel('X');  ylabel('Y'); zlabel('Z');
            patch('Faces',fs,'Vertices',cors,'FaceColor','#4DBEEE', 'FaceAlpha',0.3);
        end
    end    
end
