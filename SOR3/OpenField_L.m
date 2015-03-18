function [TimeSitting, TimeCorners, TimeOuter, TimeCenter,TimeInner,path_length,thigmotaxis,Sitting_in_periphery,TimeSitting_in_corner,Motion] = OpenField_L(COM,start_idx,frames,Info,fps,Tail,duration,box_dim)
% Get open field measurements.
% Parameters to measure:
% 1. Explore - non-straight line path, slow speed activity
% 2. Walk - straight and relatively fast locomotor activity
% 3. Sit - non-locomotor activity - minimum non-locomotion time to be
% defined as sit bout is 3s.
% 4. Risk assessment - stretch and unstretch
% 5. Divide the OF arena into regions: 4 corners, outer square,
% inner square and center square. Assign the mouse to one of these regions
% for each frame
% 6. Thigmotaxis - tendency to stay in close contact with walls = total
% time in corners + outer ring
% 7. Latency to achieve any number of things - enter corner, enter center
% square, etc.

TimeSitting=0; TimeCorners=0; TimeOuter=0; TimeCenter=0; TimeInner=0;
%% First figure out conversion from pixels to inches: box is 12x15 inch
if(isfield(Info,'perimeter') && ~isempty(Info.perimeter))
    periphery = Info.perimeter;
else
periphery = 2.0; % 2 inches from the walls is the periphery
end
% figure
% imshow(Info.ref_frame); axis image;
% hold on
C = regionprops(Info.ROIs.surface_left,'BoundingBox');
px_per_inch_L = mean([C.BoundingBox(3)/box_dim(1) C.BoundingBox(4)/box_dim(2)]);
center_BW_L = imerode(Info.ROIs.surface_left,ones(ceil(4.5*periphery*px_per_inch_L)));
inner_BW_L = imerode(Info.ROIs.surface_left,ones(ceil(2*periphery*px_per_inch_L)));
outer_BW_L = Info.ROIs.surface_left - inner_BW_L;
% Corners: 1 - top left, 2 - top left, 3 - bottom left, 4 - bottom left
ul = zeros(4,2);
ul(1,:) = [floor(C.BoundingBox(1)) floor(C.BoundingBox(2))];
ul(2,:) = [floor(C.BoundingBox(1)+C.BoundingBox(3)-periphery*px_per_inch_L) floor(C.BoundingBox(2))];
ul(3,:) = [floor(C.BoundingBox(1)) floor(C.BoundingBox(2)+C.BoundingBox(4)-periphery*px_per_inch_L)];
ul(4,:) = [floor(C.BoundingBox(1)+C.BoundingBox(3)-periphery*px_per_inch_L) floor(C.BoundingBox(2)+C.BoundingBox(4)-periphery*px_per_inch_L)];
for i=1:4
    Corners_L(i).BW = false(size(Info.ROIs.surface_left));
    for j=ul(i,1):floor((ul(i,1)+periphery*px_per_inch_L))
        for k=ul(i,2):floor((ul(i,2)+periphery*px_per_inch_L))
            Corners_L(i).BW(k,j) = 1;
        end
    end
%     outer_BW_L = outer_BW_L-Corners_L(i).BW;
end
outer_BW_L(outer_BW_L<0) = 0;
center_BW_L(center_BW_L<0) = 0;
inner_BW_L(inner_BW_L<0) = 0;

% Show the boundaries

% B = bwboundaries(Info.ROIs.surface_left);
% plot(B{1}(:,2),B{1}(:,1),'b','LineWidth',4)
% B = bwboundaries(center_BW_L);
% plot(B{1}(:,2),B{1}(:,1),'r','LineWidth',4)
% B = bwboundaries(inner_BW_L);
% plot(B{1}(:,2),B{1}(:,1),'r','LineWidth',4)
% B = bwboundaries(outer_BW_L);
% plot(B{1}(:,2),B{1}(:,1),'r','LineWidth',4)
% 
% for i=1:4
%     B = bwboundaries(Corners_L(i).BW);
%     plot(B{1}(:,2),B{1}(:,1),'g','LineWidth',4)
% end
% % Plot the mouse's trajectory
% plot(COM(start_idx:end,1),COM(start_idx:end,2),'k');


%% Assign the mouse to corner (=1), outer ring (2), inner ring (3) or center (4)
Location = single(zeros(frames-start_idx+1,1));
for i=start_idx:frames
    if(floor(COM(i,2))~=0 && floor(COM(i,1))~=0)
        if(outer_BW_L(floor(COM(i,2)),floor(COM(i,1))))
            Location(i) = 2;
        elseif(inner_BW_L(floor(COM(i,2)),floor(COM(i,1))))
            Location(i) = 3;
        elseif(center_BW_L(floor(COM(i,2)),floor(COM(i,1))))
            Location(i) = 4;
        else
            Location(i) = 1;
        end
    end
end

%% Determine the amount of time spent in each regions in 5minute intervals
% Videos should be either 10 or 30 mins long. Assuming that they are 10 min
% here

idx = floor(linspace(start_idx,frames,duration/(60*5)+1));

for i=1:length(idx)-1
    TimeCorners(1,i) = nnz(Location(idx(i):idx(i+1)-1)==1)./fps;
    TimeOuter(1,i) = nnz(Location(idx(i):idx(i+1)-1)==2)./fps;
    TimeInner(1,i) = nnz(Location(idx(i):idx(i+1)-1)==3)./fps;
    TimeCenter(1,i) = nnz(Location(idx(i):idx(i+1)-1)==4)./fps;
end
% vid_length = times(end)-times(start_idx);
% t = 0:5*60:vid_length;
% T = times-times(start_idx);
% idx = arrayfun(@(x) find(T-x>.01,1,'first'),t);
% if(isempty(idx))
%     idx = length(times);
% end
% for i=1:length(idx)-1
%     try
%     L = bwlabel(Location(idx(i):idx(i+1))==1);
%     cntr = 0;
%     for j=1:max(L)
%         cntr = cntr + times(find(L==j,1,'last')+idx(i)+1)-times(find(L==j,1,'first')+idx(i));
%     end
%     TimeCorners(i) = cntr;
%
%     L = bwlabel(Location(idx(i):idx(i+1))==2);
%     cntr = 0;
%     for j=1:max(L)
%         cntr = cntr + times(find(L==j,1,'last')+idx(i)+1)-times(find(L==j,1,'first')+idx(i));
%     end
%     TimeOuter(i) = cntr;
%
%     L = bwlabel(Location(idx(i):idx(i+1))==3);
%     cntr = 0;
%     for j=1:max(L)
%         cntr = cntr + times(find(L==j,1,'last')+idx(i)+1)-times(find(L==j,1,'first')+idx(i));
%     end
%     TimeInner(i) = cntr;
%
%     L = bwlabel(Location(idx(i):idx(i+1))==4);
%     cntr = 0;
%     for j=1:max(L)
%         cntr = cntr + times(find(L==j,1,'last')+idx(i)+1)-times(find(L==j,1,'first')+idx(i));
%     end
%     TimeCenter(i) = cntr;
% end
% end
%% Determine distance travelled in successive frames
Motion = zeros(frames,1);
for i=start_idx+1:frames
    Motion(i) = norm(COM(i,:)-COM(i-1,:));
end

%% Path length
path_length = 0;
for i=2:size(COM,1)
    delta = sqrt( (COM(i,1)-COM(i-1,1))^2 + (COM(i,2)-COM(i-1,2))^2);
    if(~isnan(delta))
        path_length = path_length + delta;
    end
end
path_length = path_length/px_per_inch_L;
for i=1:length(idx)-1
    thigmotaxis(1,i) = (TimeOuter(i)+TimeCorners(i))./(TimeOuter(i)+TimeCorners(i)+TimeInner(i)+TimeCenter(i));
end

%% Time spent sitting
if(px_per_inch_L<30)
    thr = .5;
else
    thr = 1;
end
evnts = findevents(Motion,fps,10);
for i=1:length(idx)-1
    TimeSitting(1,i) = nnz(evnts(idx(i):idx(i+1)-1)<thr)./fps;
end

%% Sitting in a corner - use tail coordinates for this
Location2 = single(zeros(frames,1));
for i=start_idx:frames
    if(floor(Tail(i,2))~=0 && floor(Tail(i,1))~=0)
        if(outer_BW_L(floor(Tail(i,2)),floor(Tail(i,1))))
            Location2(i) = 2;
        elseif(inner_BW_L(floor(Tail(i,2)),floor(Tail(i,1))))
            Location2(i) = 3;
        elseif(center_BW_L(floor(Tail(i,2)),floor(Tail(i,1))))
            Location2(i) = 4;
        else
            Location2(i) = 1;
        end
    end
end

% Sitting_in_corner = evnts<thr & (Location==1 | Location2==1);
for i=1:length(idx)-1
    TimeSitting_in_corner(1,i) = 0;
end


Motion = Motion./px_per_inch_L;



Sitting_in_periphery = 0;

