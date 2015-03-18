%%
function Sliced_Maze = SliceMaze(Info,L)
C = regionprops(L,'Centroid');
BW = Info.Maze;
[r c] = size(BW);
Maze_centroid = regionprops(BW,'Centroid');
Maze_centroid = Maze_centroid.Centroid;

%% Divide the maze into 4 wedges.
BW = Info.Maze;
% Draw line on a logical mask from centroid to ROI 2
x_c = Maze_centroid(1); y_c = Maze_centroid(2);
x = mean([C(2).Centroid(1) C(3).Centroid(1)]); y = mean([C(2).Centroid(2) C(3).Centroid(2)]);
% Parametric equation for line: X(t) = x_c + (x-x_c)*t and Y(t) = y_c +
% (y-y_c)*t

for i=0:.001:100
    try
    a = x_c + (x-x_c)*i;
    b = y_c + (y-y_c)*i;
    if(a>c || b>r || b<1 || a<1)
        break;
    end
    BW(floor(b),floor(a)) = 0;
     BW(floor(b)+1,floor(a)+1) = 0;
    BW(floor(b)-1,floor(a)-1) = 0;
    end
end
% Draw line on a logical mask from centroid to ROI 17
x_c = Maze_centroid(1); y_c = Maze_centroid(2);
x = mean([C(17).Centroid(1) C(16).Centroid(1)]); y = mean([C(17).Centroid(2) C(16).Centroid(2)]);
% Parametric equation for line: X(t) = x_c + (x-x_c)*t and Y(t) = y_c +
% (y-y_c)*t

for i=0:.001:100
    try
    a = x_c + (x-x_c)*i;
    b = y_c + (y-y_c)*i;
    if(a>c || b>r || b<1 || a<1)
        break;
    end
    BW(floor(b),floor(a)) = 0;
     BW(floor(b)+1,floor(a)+1) = 0;
    BW(floor(b)-1,floor(a)-1) = 0;
    end
end

% Draw line on a logical mask from centroid to ROI 7
x_c = Maze_centroid(1); y_c = Maze_centroid(2);
x = mean([C(7).Centroid(1) C(8).Centroid(1)]); y = mean([C(7).Centroid(2) C(8).Centroid(2)]);
% Parametric equation for line: X(t) = x_c + (x-x_c)*t and Y(t) = y_c +
% (y-y_c)*t

for i=0:.001:100
    try
    a = x_c + (x-x_c)*i;
    b = y_c + (y-y_c)*i;
    if(a>c || b>r || b<1 || a<1)
        break;
    end
    BW(floor(b),floor(a)) = 0;
     BW(floor(b)+1,floor(a)+1) = 0;
    BW(floor(b)-1,floor(a)-1) = 0;
    end
end

% Draw line on a logical mask from centroid to ROI 11
x_c = Maze_centroid(1); y_c = Maze_centroid(2);
x = mean([C(11).Centroid(1) C(12).Centroid(1)]); y = mean([C(11).Centroid(2) C(12).Centroid(2)]);
% Parametric equation for line: X(t) = x_c + (x-x_c)*t and Y(t) = y_c +
% (y-y_c)*t

for i=0:.001:100
    try
    a = x_c + (x-x_c)*i;
    b = y_c + (y-y_c)*i;
    if(a>c || b>r || b<1 || a<1)
        break;
    end
    BW(floor(b),floor(a)) = 0;
    BW(floor(b)+1,floor(a)+1) = 0;
    BW(floor(b)-1,floor(a)-1) = 0;
    end
end

BW = bwlabel(imerode(BW,ones(5)));

if(max(max(BW))==4)
    % Relabel the image such that
    % Quadrant 1: target hole, holes 1,2 and -1,-2
% Quadrant 4: opposite hole, 8,9,-8,-9
% Quadrant 2: 3,4,5,6,7
% Quadrant 3: -3,-4,-5,-6,-7
    quad1 = BW(floor(C(20).Centroid(2)),floor(C(20).Centroid(1)));
    quad2 = BW(floor(C(5).Centroid(2)),floor(C(5).Centroid(1)));
    quad3 = BW(floor(C(14).Centroid(2)),floor(C(14).Centroid(1)));
    quad4 = BW(floor(C(19).Centroid(2)),floor(C(19).Centroid(1)));
    
    Sliced_Maze = zeros(size(BW));
    Sliced_Maze(BW==quad1) = 1;
    Sliced_Maze(BW==quad2) = 2;
    Sliced_Maze(BW==quad3) = 3;
    Sliced_Maze(BW==quad4) = 4;
else
    Sliced_Maze = zeros(size(BW));
end
    