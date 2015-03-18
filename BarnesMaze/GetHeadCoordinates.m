function [xhead, yhead,xtail,ytail,Vision,COM,MAL] = GetHeadCoordinates(L)
% Given a segmentation of a mouse, find head and tail coordinates. Often,
% the body of the mouse may be separated from the tail in segmentation.
% Body = 1, tail = 2. In this case, find the endpoints of body and tail to
% figure out where the head is.
if(nnz(L==2))
    % Tail is separate. Find the endpoints of the body
    BW = L==1;
    C = regionprops(BW,'Centroid');
    COM = C.Centroid;
    if(BW(floor(COM(2)),floor(COM(1)))==0)
        BW = imdilate(BW,strel('disk',3));
    end
    D = bwdistgeodesic(BW,floor(COM(1)),floor(COM(2)),'quasi-euclidean');
    [~,x] = max(D(:));
    [y,x]=ind2sub(size(D),x);
    x1 = x;
    y1 = y;
    D = bwdistgeodesic(BW,x1,y1,'quasi-euclidean');
    [~,x] = max(D(:));
    [y,x]=ind2sub(size(D),x);
    x2 = x;
    y2 = y;
    
     BW = L==2;
    C = regionprops(BW,'Centroid');
    COM = C.Centroid;
    if(BW(floor(COM(2)),floor(COM(1)))==0)
        BW = imdilate(BW,strel('disk',3));
    end
    D = bwdistgeodesic(BW,floor(COM(1)),floor(COM(2)),'quasi-euclidean');
    [~,x] = max(D(:));
    [y,x]=ind2sub(size(D),x);
    x3 = x;
    y3 = y;
    D = bwdistgeodesic(BW,x3,y3,'quasi-euclidean');
    [~,x] = max(D(:));
    [y,x]=ind2sub(size(D),x);
    x4 = x;
    y4 = y;
    
    % Now find the two points that are closest to each other - these are
    % the base of the tail. 
    DIST = @(a,b,c,d) sqrt( (a-c)^2 + (b-d)^2);
    D = zeros(4,1);
    D(1) = DIST(x1,y1,x3,y3); % distance from 1 to 3
    D(2) = DIST(x1,y1,x4,y4); % 1 to 4
    D(3) = DIST(x2,y2,x3,y3); % 2 to 3
    D(4) = DIST(x2,y2,x4,y4); % 2 to 4
    [~,idx] = min(D);
    switch idx
        case 1
            xhead = x2;
            yhead = y2;
            xtail = x4;
            ytail = y4;
        case 2
            xhead = x2;
            yhead = y2;
            xtail = x3;
            ytail = y3;
        case 3
            xhead = x1;
            yhead = y1;
            xtail = x4;
            ytail = y4;
        case 4
            xhead = x1;
            yhead = y1;
            xtail = x3;
            ytail = y3;
    end
else
BW = L==1;
C = regionprops(BW,'Centroid');
if(isempty(C))
    COM = [0 0];
else
   
COM = C(1).Centroid;
end
% Identify the tail as the farthest point from COM

% If COM is not on the object, dilate the object slightly
if(BW(floor(COM(2)),floor(COM(1)))==0)
    BW = imdilate(BW,strel('disk',3));
end

%% farthest geodesic distance from COM = tail, farthest point from tail = head

D = bwdistgeodesic(BW,floor(COM(1)),floor(COM(2)),'quasi-euclidean');
[~,x] = max(D(:));
[y,x]=ind2sub(size(D),x);
xtail = x;
ytail = y;

% Identify the head as fartherst point from the tail
D = bwdistgeodesic(BW,xtail,ytail,'quasi-euclidean');
[MAL,x] = max(D(:));
[y,x]=ind2sub(size(D),x);
xhead = x;
yhead = y;
end


%% Pixel density in a 10x10 region around head and tail locations
% head_density = nnz(L(yhead-5:yhead+5,xhead-5:xhead+5));
% tail_density = nnz(L(ytail-5:ytail+5,xtail-5:xtail+5));
% 
% if(tail_density>33 || abs(head_density-tail_density)<=3)
%     disp('FLIPPED');
%     tmp1 = xhead; tmp2 = yhead;
%     xhead = xtail;
%     yhead = ytail;
%     xtail = tmp1;
%     ytail = tmp2;
% end
% 

%%
% Draw a vision vector from COM to head
Vision = [xhead-COM(1);yhead-COM(2)];
MAL = 0;    
BW = L==1;
C = regionprops(BW,'Centroid');
COM = C(1).Centroid;