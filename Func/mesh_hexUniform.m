function [node,element]=Hex_getMesh(p0, len, n, isHex)
nnx = n(1) + 1;
nny = n(2) + 1;
nnz = n(3) + 1;

x1d = linspace(p0(1), p0(1)+len(1), nnx);
y1d = linspace(p0(2), p0(2)+len(2), nny);
z1d = linspace(p0(3), p0(3)+len(3), nnz);

count = 1;
node = zeros(nnz*nny*nnx,3);
for k=1:nnz
    for j=1:nny
        for i=1:nnx
            node(count,:) = [x1d(i) y1d(j) z1d(k)];
            count = count + 1;
        end
    end
end

if isHex

    chan  = zeros(nnz,nny,nnx);
    count = 1;
    for i=1:nnz
        for j=1:nny
            for k=1:nnx
                chan(i,j,k) = count;
                count       = count + 1;
            end
        end
    end

    connecU = zeros(nnx-1,2);
    connecV = zeros(nny-1,2);
    connecW = zeros(nnz-1,2);

    for i=1:size(connecU,1)
        connecU(i,:) = [i i+1];
    end

    for i=1:size(connecV,1)
        connecV(i,:) = [i i+1];
    end

    for i=1:size(connecW,1)
        connecW(i,:) = [i i+1];
    end

    noElems  = (nnx-1) * (nny-1) * (nnz-1);
    element = zeros(noElems,8);

    e = 1;
    for w=1:nnz-1
        wConn = connecW(w,:);
        for v=1:nny-1
            vConn = connecV(v,:);
            for u=1:nnx-1
                c = 1;
                uConn = connecU(u,:);

                for i=1:length(wConn)
                    for j=1:length(vConn)
                        for k=1:length(uConn)
                            element(e,c) = chan(wConn(i),vConn(j),uConn(k));
                            c = c + 1;
                        end
                    end
                end
                e = e + 1;
            end
        end
    end

    % renumbering nodes according to Jack Chessa's code
    col3 = element(:,3);
    col4 = element(:,4);
    col7 = element(:,7);
    col8 = element(:,8);

    element(:,3) = col4;
    element(:,4) = col3;
    element(:,7) = col8;
    element(:,8) = col7;
else
    TR = delaunayTriangulation(node);
    element = TR.ConnectivityList;
end
end