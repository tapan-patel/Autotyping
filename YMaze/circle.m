%% Show frames where mouse is classified as being in the open region
idx = find(Location);
for i=1:length(idx)
    v = mmread(Info.filename,idx(i));
    imshow(v(end).frames.cdata);
    num2str(idx(i));
    pause;
end

%% Inter-event interval

t_begin = times(Info.start_idx);
t_end = t_begin + 300;
end_idx = find(times-t_end>.1,1,'first');
L = Location(Info.start_idx:end_idx);
t = times(Info.start_idx:end_idx)-Info.start_time;

Copen = regionprops(L,'Area');
Aopen = [Copen.Area];
Cclose = regionprops(~L,'Area');
Aclose = [Cclose.Area];
Lopen = bwlabel(L);
Lclose = bwlabel(~L);

Topen = zeros(max(Lopen),1);
for i=1:max(Lopen)
    idx = find(Lopen==i);
    Topen(i) = t(idx(1));
end


%% Get the maze
imshow(Info.ref_frame);
h = imellipse;
BWin = h.createMask;
h = imellipse;
BWout = h.createMask;

% Center of inner circle
Cin = regionprops(BWin,'Centroid','MajorAxisLength','MinorAxisLength','EquivDiameter');
xc = Cin.Centroid(1); yc = Cin.Centroid(2);

Cout = regionprops(BWout,'MajorAxisLength','MinorAxisLength','EquivDiameter');
rx = mean([Cin.MajorAxisLength Cout.MajorAxisLength])/2;
ry = mean([Cin.MinorAxisLength Cout.MinorAxisLength])/2;
r = mean([Cin.EquivDiameter Cout.EquivDiameter])/2;
%%
v = fitresult.p1;
% v=20;
theta = v/r*t ;
x = rx*cos(theta) + xc;
y = ry*sin(theta) + yc;

%% PathLength for uniform motion
PathLength = zeros(length(x),1);
for i=2:length(x)
    PathLength(i) = Distance(x(i),y(i),x(i-1),y(i-1));
end
Ambulation = cumsum(PathLength);

%%
Location_ideal = false(length(x),1);
for i=1:length(x)
            if(Info.ROIs.Open1(floor(y(i)),floor(x(i))) || Info.ROIs.Open2(floor(y(i)),floor(x(i))))
            Location_ideal(i) = 1;
        end
end
%% fps
fitresult1 = createFit1(1:length(t),t');

%% Amount of time spent in open and closed regions
TimeOpen_ideal = sum(Location_ideal==1)/29.9696;
TimeClose_ideal = sum(Location_ideal==0)/29.9696;
C = bwlabel(Location_ideal);
CO = max(C);
C = bwlabel(~Location_ideal);
OC = max(C);

%% Distance to the pattern
D = sum(Location~=Location_ideal)/length(Location);

D = sum(Lphantom~=Location_ideal)/length(Lphantom);