% see plot_mesh
function h1 = plot_femMesh(p_cor, ele_p, fig1)

np = size(p_cor,1); ne = size(ele_p,1);    nep = size(ele_p,2);


if nep == 8
    cc = [2,3,7,6
        5,8,4,1
        6,5,1,2
        3,4,8,7
        4,3,2,1
        5,6,7,8];
    fs = zeros(ne*6,4);
    for ii = 1:ne
        % ---- the pe
        tps = ele_p(ii,:);
        fs(ii*6-5:ii*6,:) = tps(cc);
    end
elseif nep == 4
    cc = [1,2,3
        2,3,4
        3,4,1
        4,1,2];
    fs = zeros(ne*4,3);
    for ii = 1:ne
        % ---- the pe
        tps = ele_p(ii,:);
        fs(ii*4-3:ii*4,:) = tps(cc);
    end
end

h1=figure (fig1); clf;
patch('Faces',fs,'Vertices',p_cor,'FaceColor',	'#4DBEEE','FaceAlpha',0.9);   
axis equal
xlabel('x');  ylabel('y'); zlabel('z');
view(-37.5,30);
end

function plot_mesh(X,connect,elem_type,se,linewidth)

% function plot_mesh(X,connect,elem_type,linespec)
% 
% plots a nodal mesh and an associated connectivity.  X is
% teh nodal coordinates, connect is the connectivity, and
% elem_type is either 'L2', 'L3', 'T3', 'T6', 'Q4', or 'Q9' 
% depending on the element topology.
  
if ( nargin < 4 )
   se='w-';
end

holdState=ishold;
hold on

% fill X if needed
if (size(X,2) < 3)
   for c=size(X,2)+1:3
      X(:,c)=[zeros(size(X,1),1)];
   end
end

for e=1:size(connect,1)
  
   if ( strcmp(elem_type,'Q9') )       % 9-node quad element
      ord=[1,5,2,6,3,7,4,8,1];
   elseif ( strcmp(elem_type,'Q8') )  % 8-node quad element
      ord=[1,5,2,6,3,7,4,8,1];
   elseif ( strcmp(elem_type,'T3') )  % 3-node triangle element
      ord=[1,2,3,1];
   elseif ( strcmp(elem_type,'T6') )  % 6-node triangle element
      ord=[1,4,2,5,3,6,1];
   elseif ( strcmp(elem_type,'Q4') )  % 4-node quadrilateral element
      ord=[1,2,3,4,1];
   elseif ( strcmp(elem_type,'L2') )  % 2-node line element
      ord=[1,2];   
   elseif ( strcmp(elem_type,'L3') )  % 3-node line element
      ord=[1,3,2];   
   elseif ( strcmp(elem_type,'H4') )  % 4-node tet element
      ord=[1,2,4,1,3,4,2,3];   
   elseif ( strcmp(elem_type,'B8') )  % 8-node brick element
      ord=[1,5,6,2,3,7,8,4,1,2,3,4,8,5,6,7];   
   end
   
   for n=1:size(ord,2)
      xpt(n)=X(connect(e,ord(n)),1);
      ypt(n)=X(connect(e,ord(n)),2);      
      zpt(n)=X(connect(e,ord(n)),3);
   end
   h=plot3(xpt,ypt,zpt,se);
   set(h,'LineWidth',linewidth);
   set(h,'MarkerSize',7);
end

rotate3d on
axis equal
      
if ( ~holdState )
  hold off
end
end

