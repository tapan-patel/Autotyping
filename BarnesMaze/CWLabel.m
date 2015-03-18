function Lnew = CWLabel(Maze,L,escape_box)
% Given a label matrix, number of ROIs (N), and escape box, label it st
% escape box is 0, ROIs cw are + and ROIs ccw are -. 
C = regionprops(Maze,'Centroid','MajorAxisLength');
x_c = C.Centroid(1); y_c = C.Centroid(2);

diameter = C.MajorAxisLength;
r = diameter/2;
L = bwlabel(L);
C = regionprops(L,'Centroid');

% Angle of 20 holes relative to +x axis.
Angles = zeros(20,1);
for i=1:20
    Angles(i) = GetAngle(C(i).Centroid(1),C(i).Centroid(2),x_c,y_c);
end

% Number the holes st target hole is 20, opposite hole is 19, 1-9 are
% 180-360 and 10-18 are 0-180 degrees

% Make target angle 0
Angles = Angles - Angles(escape_box);
Angles = mod(Angles,360);

opposite_box = find(abs(Angles-180)<10);

Lnew = zeros(size(L));

[theta,idx] = sort(Angles);
for i=1:20
    if(i==1)
        Lnew(L==idx(i)) = 20;
    end
    if(i==11)
        Lnew(L==idx(i)) = 19;
    end
    if(i>1 && i<11)
        Lnew(L==idx(i)) = i-1;
    end
    if(i>11)
        Lnew(L==idx(i)) = i-2;
    end
end