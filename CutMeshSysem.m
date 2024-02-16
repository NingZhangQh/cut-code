% A class to generate cutmesh on a block
% === n_zhang_qh@163.com  NingZhang===
classdef CutMeshSysem < handle % Convex3d
    properties (Constant, Access = private)
        CUBE_F = {[4,1,5,8];[2,3,7,6];[1,2,6,5];[3,4,8,7];[4,3,2,1];[5,6,7,8]};
        CUBE_OUTLINE = [1,5,6,2,3,7,8,4,1,2,3,4,8,5,6,7];
    end
    
    properties
        bk          % ConvexSystem
        
        e_mp      % ne*8 element nodes 
        mp_cor   % np*3 node coordinates
        
        e_con     % ne*2 [startID-1, nConInE]
        con_Cor  % nc*1 cell Vertices of convex
        con_F      % nc*1 cell Faces of convex
    end
    
    
    methods
        function obj = CutMeshSysem(tbk)
            if sum(tbk.tag) ~= 1
                disp("Only 1 block is supported. Please treat blocks one by one")
            else
                obj.bk = tbk;
            end
        end
        
        function plot_byFace(obj, fid)
            meLineWidth = 0.2;
            %% 1 for pe
            ncon = sum(obj.e_con(:,2));
            
            % nf,  fnpMax,   con_p0
            con_p0  = zeros(ncon, 1);
            fnpMax = 0;     nf =0;      pid = 0;
            
            for ii = 1:ncon
                tF = obj.con_F{ii};
                for jj =1:size(tF,1)
                    cc = size(tF{jj},2);
                    if cc > fnpMax
                        fnpMax = cc ;
                    end
                end
                nf = nf + size(tF,1);
                
                % con_np
                con_p0(ii) = pid;
                pid           = pid + size(obj.con_Cor{ii},1);
            end
            
            % parepare faces and cors
            cors = cat(1, obj.con_Cor{:});
            fs = nan(nf, fnpMax);   iface = 0;
            for ii = 1:ncon
                tF = obj.con_F{ii};
                for jj =1:size(tF,1)
                    fs(iface+1,1: size(tF{jj},2)) = tF{jj} + con_p0(ii);
                    
                    % next
                    iface = iface + 1;
                end
            end
            
            figure(fid);  clf;
            axis equal; view(-37.5,30);  xlabel('X');  ylabel('Y'); zlabel('Z');
            patch('Faces',fs,'Vertices',cors,'FaceColor','#4DBEEE','FaceAlpha',1);
                        
            %% for me            
            if meLineWidth>0
                ne = size(obj.e_mp,1);        edges = obj.CUBE_OUTLINE;
                xy = nan(ne*(16+2),  3);     mp0 = 0;
                
                cor = obj.mp_cor;
                for ii = 1:ne
                    % add mp
                    mp = obj.e_mp(ii,:);
                    xy(mp0+1: mp0+16,:) = cor(mp(edges),:);
                    mp0 = mp0 + 16 + 2;
                end
                
                hold on;
                plot3(xy(:,1),xy(:,2),xy(:,3), 'r', 'linewidth', meLineWidth); % me
            end
        end
       
        %{
            meshH: 1*1 value, the size of the cube
            meshP0: a point [x, y, z] contained in the mp. This can always take [0,0,0]
        %}
        function set_mesh(obj, meshH, meshP0)
            
            tbk = obj.bk;
            Cs = tbk.C;    nc   = tbk.count;
            
            % get mesh nn
            box = tbk.get_box();
            minCor = min(box(:, 1:2:end));    
            maxCor = max(box(:, 2:2:end));
            
            minCor = meshP0 + floor((minCor-meshP0)/meshH) *meshH;
            nn   = ceil( (maxCor-minCor)/meshH);
            
            % get ini hex mesh
            [tmp_cor, te_mp] = mesh_hexUniform(minCor, meshH*nn, nn, true);
            
            %% 2 [e_mp] 
            [te_isPossInC, te_isFE] = sub_checkEleIn(Cs, tmp_cor, te_mp, meshH);
            
            te_used     = any(te_isPossInC,2);
            
            % del
            te_mp         = te_mp(te_used,:);
            te_isFE        = te_isFE(te_used,:);
            te_isPossInC= te_isPossInC(te_used,:);
            
            ne          = size(te_mp,1);    
            te_con    = zeros(ne, 2);
            
            ncon       = 0;
            tcon_Cor = cell(ne, 1);      
            tcon_F     = cell(ne,1);    
            
            %% 3 [] intersection
            te_del = false(ne,1);         
            for ii = 1:ne                  
                ncon0 = ncon;
                if te_isFE(ii)      
                    ncon = ncon + 1;                    
                    tcon_Cor{ncon} = tmp_cor(te_mp(ii,:), :);
                    tcon_F{ncon}    = CutMeshSysem.CUBE_F;
                else                       
                    for jj = 1:nc
                        if ~te_isPossInC(ii, jj)
                            continue
                        end
                        
                        % try find a new
                        [~, jCor, jF] = sub_cutWithCube...
                            (Cs{jj}, tmp_cor(te_mp(ii,1), :), meshH);
                        if ~isempty(jCor)
                            ncon = ncon + 1;
                            tcon_Cor{ncon}    = jCor;
                            tcon_F{ncon} = jF;
                        end
                    end
                end
                % check effect
                if ncon > ncon0
                    te_con(ii, 1) = ncon0;    te_con(ii, 2) = ncon-ncon0;
                else
                    te_del(ii) = true;
                end
            end
            % clear
            te_con(te_del,:) = [];   te_mp(te_del,:) = [];   te_isFE(te_del,:) = [];
            
            nmp = size(tmp_cor,1);
            mpNewId = zeros(nmp,1);
            mpNewId(te_mp) = 1;   cc = find(mpNewId);
            mpNewId(cc) = 1:numel(cc);
            
            tmp_cor = tmp_cor(cc,:);   te_mp = mpNewId(te_mp);
            
            % assign
            obj.e_mp = te_mp;    obj.mp_cor = tmp_cor;
            obj.e_con = te_con;   obj.con_Cor = tcon_Cor;   obj.con_F = tcon_F; 
        end        
    end
end


%{
    prechecking to decide if need cut
%}
function [e_isPossInC, e_isFE] = sub_checkEleIn(Cs, mp_cor, e_mp, meshH)
nC = size(Cs,1);

% 1 check strict
mp_strictIn = Con3_pointIsIn(Cs{1}, mp_cor, 1e-6);
for ii = 2:nC
    mp_strictIn = mp_strictIn | Con3_pointIsIn(Cs{ii}, mp_cor, 1e-6);
end

e_isFE = all(mp_strictIn(e_mp),2);

% 2 check rough (note, Circumscribed sphere: r = sqrt3/2 a)
TolRough = 0.8661 * meshH;
e_mid = 0.5*(mp_cor(e_mp(:,1),:) + mp_cor(e_mp(:,7),:));

e_isPossInC = false(size(e_mp,1), nC);
for ii = 1: nC
    e_isPossInC(:,ii) = Con3_pointIsIn(Cs{ii}, e_mid, TolRough);
end
end

%{
    if need cut, do this
%}
function [C, cor, F] = sub_cutWithCube(C, p0, H)
% p0: first point of the cube
C = [C
    0,-p0(1), -1, 0, 0
    0, p0(1)+H,  1, 0, 0
    0,-p0(2),      0,-1, 0
    0, p0(2)+H,  0, 1, 0
    0,-p0(3),      0, 0,-1
    0, p0(3)+H,  0, 0, 1];

[C, cor] = Con3_updateByC(C);

if ~isempty(cor) % no cor
    [C, F] = Con3_updateFace(C, cor);
    if ~isempty(C)  % row of C less than 4
        return
    end
else
    C = [];  F = [];  cor = [];
end
end


