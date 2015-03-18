function total_time = ExploreTime(abs_mv_path)
% Compute how long the mouse spends outside the zero-maze.
% Algorithm: user needs to select a frame # when to start analysis. Couple
% frames after that, segment mouse using a frame in the beginning part of
% the video that doesn't have a mouse as reference. Compute the area of
% this mouse. For each frame, compute the area of the segmented mouse and
% its centroid.

filename = abs_mv_path;
%% Read in a movie file
try
    disp(['Creating video reader object for  ' filename]);
    VIDOBJ_IN = mmreader(filename);
catch
    disp(['COULD NOT READ ' filename '. Cancel this function Ctrl+C and rerun']);
    pause
    return
end

disp(['Processing ' filename]);
% If number of frames was not detected,read in the last frame to determine the number of frames

if(isempty(VIDOBJ_IN.NumberOfFrames))
    read(VIDOBJ_IN,inf);
end

frames = VIDOBJ_IN.NumberOfFrames;

%% Use mmread to read the frames so that the timestamps are also recorded
clear VIDOBJ_IN;
times = zeros(frames,1);

% Read an image of reference frame - empty maze
v = mmread(abs_mv_path,5);
Iref = rgb2gray(v(end).frames.cdata);


% Show the empty maze to user and ask to freehand draw the areas of open
% maze.
figure
imshow(v(end).frames.cdata);

% First need to get the region of entire maze.
hmaze = imrect;
BWmaze = hmaze.createMask;
BWmaze = uint8(BWmaze);
% Now need the user to select the open areas of the maze
hopen = imfreehand;
BWopen1 = hopen.createMask;
hopen = imfreehand;
BWopen2 = hopen.createMask;

BWopen = BWopen1 + BWopen2;
BWopen = uint8(BWopen);

dmax = zeros(frames,1);
Area = zeros(frames,1);
Centroid = zeros(frames,2);

Iref = Iref.*BWmaze;
parfor i=1:frames
    
    v = mmread(abs_mv_path,i);
    times(i) = v(end).times;
    I = rgb2gray(v(end).frames.cdata);
    I = I.*BWmaze;
    dmax(i) = sum(sum(imabsdiff(I,Iref)));
    
    % Detect a mouse with threshold intensity >90 from reference
    D = imabsdiff(I,Iref);
    BW = D>90;
    L = bwlabel(BW);
    C = regionprops(L,'Area','Centroid');
    if(~isempty(C))
        [~,IDX] = sort([C.Area],'descend');
        Centroid(i,:) = C(IDX(1)).Centroid;
        
        Lnew = zeros(size(L));
        Lnew(L==IDX(1))=1;
        Lnew = uint8(Lnew);
        % Confine to the open area
        Lnew = Lnew.*BWopen;
        C = regionprops(Lnew,'Area');
        if(~isempty(C))
            Area(i) = C(1).Area;
        end
    end
end

% Now figure out when the mouse was placed
thr = mean(dmax)+2*std(dmax);
bw = dmax<thr;
L = bwlabel(bw);
C = regionprops(L,'Area');
A = [C.Area];
[~,ROI] = max(A);

t = times(L==ROI);
MouseArea =  Area(L==ROI);
Centroid = Centroid(L==ROI,:);

% Need to figure out the area of a mouse to threshold on - assume that the
% mouse is first placed inside the maze and compute its area
i=find(L==ROI,1);
v = mmread(abs_mv_path,i);
I = rgb2gray(v(end).frames.cdata);
I = I.*BWmaze;
D = imabsdiff(I,Iref);
BW = D>90;
L = bwlabel(BW);
C = regionprops(L,'Area');
if(~isempty(C))
    [~,IDX] = sort([C.Area],'descend');
    Lnew = zeros(size(L));
    Lnew(L==IDX(1))=1;
    Lnew = uint8(Lnew);
    C = regionprops(Lnew,'Area');
    if(~isempty(C))
        thr_area = C(1).Area*.9;
    end
else
    thr_area = 4e3;
end

% Find the total times when the mouse is outside the maze
t_outside = t(MouseArea>thr_area);

BW = MouseArea>thr_area;
L = bwlabel(BW);
total_time = 0;

for i=1:max(L)
    try
    total_time = total_time + t(find(L==i,1,'last')+1)-t(find(L==i,1,'first'));
    end
end