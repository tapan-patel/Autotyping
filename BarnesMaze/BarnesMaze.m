%% Barnes maze
function analysis = BarnesMaze(Info,varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania
abs_mv_path = Info.filename;
[~,vidname] = fileparts(Info.filename);
hbar = waitbar(0,sprintf('Processing %s\n0%%', vidname));
set(findall(hbar,'type','text'),'Interpreter','none');
frames = mmcount(abs_mv_path);

if(isnan(frames))
    vid = VideoReader(abs_mv_path);
    
    if(isempty(vid.NumberOfFrames))
        read(vid,inf);
    end
    
    frames = vid.NumberOfFrames;
end
DISPLAY = 0;
if nargin > 2
    for i = 1:2:length(varargin)-1
        if isnumeric(varargin{i+1})
            eval([varargin{i} '= [' num2str(varargin{i+1}) '];']);
        else
            eval([varargin{i} '=' char(39) varargin{i+1} char(39) ';']);
        end
    end
end


%%
diameter = regionprops(Info.Maze,'MajorAxisLength');
diameter = diameter.MajorAxisLength;
px_per_inch = diameter/36;
start_idx = Info.start_idx;
if(start_idx<=0)
    start_idx = TimeToFrame(abs_mv_path,1,frames,Info.start_time);
end

frames = TimeToFrame(abs_mv_path,1,frames,Info.end_time);

times = zeros(frames,1);
COM = zeros(frames,2);
Eyes = zeros(frames,2);
Location = zeros(frames,1);
Location_expanded = zeros(frames,1);
% Read f frames at a time
f = 100;
T = [start_idx:f:frames frames];
[~,vidname] = fileparts(abs_mv_path);
disp(vidname);
fname = tempname(pwd);
parfor_progress(length(T),fname,vidname);
global cancel;
cancel = 0;
if(DISPLAY)
    h=figure;
    hax = axes('Units','pixels');
    uicontrol('Style', 'pushbutton', 'String', 'Cancel',...
        'Position', [20 20 50 20],...
        'Callback', {@pushbutton_callback});
end

Bkg = Info.Bkg;
Maze = Info.Maze;
%%% DO NOT issue bwlabel(L) command. ROIs are labeled such that #20 is the
%%% escape box, #19 is opposite the escape box, 1-9 are ccw from escape box
%%% and (10-18)-19 are cw from escape box
L = Info.L;
L = imdilate(L,strel('disk',ceil(.25*px_per_inch)));
L_expanded = imdilate(L,strel('disk',ceil(px_per_inch)));


Icomposite = zeros(size(Bkg));

for k=1:length(T)-1
    if(cancel==1)
        delete(h);
        delete(hbar);
        return;
    end
    V = mmread(abs_mv_path,T(k):T(k+1)-1);
    n = length(V(end).frames);
    waitbar(T(k)/frames,hbar,sprintf('Processing %s\n%d %%',vidname,round(100*T(k)/frames)));
    set(findall(hbar,'type','text'),'Interpreter','none');
    
    % Track the mouse
    for j=1:n
        if(cancel==1)
            delete(h);
            delete(hbar);
            return;
        end
        
        try
            i = T(k)+j-1;
            times(i) = V(end).times(j);
           
            I = (rgb2gray(V.frames(j).cdata));
            D = imabsdiff(I,Bkg);
            D = D.*uint8(Maze);
            D = imfill(D,'holes');
            D = imclose(D,ones(5));
            thresh = max([60 255*graythresh(D)]);
            Lmouse = SegmentMouse(D>thresh,D,1);
            % If an object is detected...
            if(nnz(Lmouse)>0)
                Icomposite = Icomposite+Lmouse;
                [xhead, yhead] = GetHeadCoordinates(Lmouse);
                C = regionprops(Lmouse,'Centroid');
                COM(i,:) = C(1).Centroid;
                Eyes(i,:) = [xhead yhead];
                % If the head is over any part of the hole, count it as a nose poke
                
                if(L(floor(yhead),floor(xhead)))
                    Location(i) = L(floor(yhead),floor(xhead));
                end
                if(L(floor(COM(i,2)),floor(COM(i,1))))
                    Location(i) = L(floor(COM(i,2)),floor(COM(i,1)));
                end
                if(L_expanded(floor(yhead),floor(xhead)))
                    Location_expanded(i) = L_expanded(floor(yhead),floor(xhead));
                end
                if(DISPLAY)
                    imshow(I,'Parent',hax);
                    hold on
                    plot(xhead,yhead,'go');
                    if(Location(i))
                        B1 = bwboundaries(L==Location(i));
                        plot(B1{1}(:,2),B1{1}(:,1),'b','LineWidth',4);
                    end
                    title(['Elapsed time: ' num2str(floor(times(i)-times(start_idx+2))) ' (s)']);
                    %         %
                    drawnow;
                    
                    hold off
                    pause(1e-3)
                end
            else
                COM(i,:) = COM(i-1,:);
                Eyes(i,:) = Eyes(i-1,:);
                Location(i) = Location(i-1);
                Location_expanded(i) = Location_expanded(i-1);
            end
            
            
        end
    end
    parfor_progress(-1,fname,vidname);
end
%%
try
    delete(h);
end
if(times(start_idx)==0)
    start_idx = find(times,1,'first');
end
% Nose pokes that last less than 500ms have to be eliminated
L_location = bwlabel(Location);
for i=1:max(L_location)
    i1 = find(L_location==i,1,'first');
    i2 = find(L_location==i,1,'last');
    if( (times(i2)-times(i1))<.5)
        Location(L_location==i) = 0;
    end
end
% Latency to escape box - always set as #20
latency_idx = find(Location==20,1,'first');
if(isempty(latency_idx))
    latency_idx = frames-1;
end
latency = times(latency_idx)-times(start_idx);


% Distance to escape box
x = COM(:,1); y = COM(:,2);
path_len = 0;
for i=start_idx:latency_idx-1
    if(x(i)~=0 && y(i)~=0 && x(i+1)~=0 && y(i+1)~=0)
        path_len = path_len + sqrt( (x(i+1)-x(i))^2 + (y(i+1)-y(i))^2);
    end
end
dist_to_escape = path_len/px_per_inch;

% Total distance
path_len = 0;
for i=start_idx:frames-1
    if(x(i)~=0 && y(i)~=0 && x(i+1)~=0 && y(i+1)~=0)
        path_len = path_len + sqrt( (x(i+1)-x(i))^2 + (y(i+1)-y(i))^2);
    end
end
total_dist = path_len/px_per_inch;

% Number of errors before reaching the escape box
L_location = bwlabel(Location);
errors = 0;
for i=1:max(L_location)
    idx = find(L_location==i,1,'first');
    if(Location(idx)==20)
        break;
    else
        errors = errors+1;
    end
end

% Nose poke times-stamps and duration of each nose poke, sorted by ROIs
NosePoke_timestamps = cell(20,1);
NosePoke_durations = cell(20,1);
for k=1:20
    [a,b] = Bouts(Location,k,times,start_idx);
    NosePoke_timestamps(k) = {a};
    NosePoke_durations(k) = {b};
end

%% Figure
% Plot the duration of nosepokes per ROI
ROIs = {'-9','-8','-7','-6','-5','-4','-3','-2','-1','T','1','2','3','4','5','6','7','8','9','O'};
Durations =zeros(20,1);
for i=1:9
    Durations(i) = sum(NosePoke_durations{i+9});
end
Durations(10) = sum(NosePoke_durations{20});
for i=11:19
    Durations(i) = sum(NosePoke_durations{i-10});
end
Durations(20) = sum(NosePoke_durations{19});

% Determine the time spent in each of the 4 quadrants
% Quadrant 1: target hole, holes 1,2 and -1,-2
% Quadrant 4: opposite hole, 8,9,-8,-9
% Quadrant 2: 3,4,5,6,7
% Quadrant 3: -3,-4,-5,-6,-7
Time_in_quadrants = zeros(4,1);
Sliced_Maze = SliceMaze(Info,L);

for i=start_idx:length(COM)
    if(COM(i,1)~=0 && COM(i,2)~=0)
        try
            Time_in_quadrants(Sliced_Maze(floor(COM(i,2)),floor(COM(i,1)))) = Time_in_quadrants(Sliced_Maze(floor(COM(i,2)),floor(COM(i,1))))+1;
        end
    end
end
Time_in_quadrants = Time_in_quadrants./V.rate;

analysis.Time_in_quadrants = Time_in_quadrants;
%% Figure
% Plot the trajectory
hsum = figure;
subplot(2,2,1); imshow(Bkg);
% Time spent around each hole
% Place title with summary infoimshow(Bkg.*uint8(Maze)); axis image;
hold on
plot(x(x~=0),y(x~=0),'b','LineWidth',2);
% Outline the escape hole
B1 = bwboundaries(L==20);
plot(B1{1}(:,2),B1{1}(:,1),'r','LineWidth',2);
C = regionprops(L,'Centroid');
for i=1:20
    if(i==20)
        plot(text(C(i).Centroid(1)+30,C(i).Centroid(2)+20,'T','Color','r','FontSize',16,'Rotation',45));
    end
    if(i==19)
        plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,'O','Color','r','FontSize',16,'Rotation',-45));
    end
    if(i<10)
        plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,num2str(i),'Color','r','FontSize',16));
    end
    if(i>=10 && i~=20 && i~=19)
        plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,num2str(i-19),'Color','r','FontSize',16));
    end
end

title_str = sprintf('%s\nLatency to escape: %.2f (s), Distance to escape: %.2f", Total distance: %.2f",  # of errors: %d',abs_mv_path,latency,dist_to_escape,total_dist,errors);
title(title_str,'Interpreter','none');
freezeColors

subplot(2,2,2); imagesc(Icomposite/V.rate); colorbar; axis image;set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]); colormap('jet'); hold on
title_str = sprintf('Time in quadrant 1 (T,1,2,-1,-2): %.2f (s); quadrant 2 (3-7): %.2f (s)\n quadrant 3 (-3 to -7): %.2f (s); quadrant 4 (-8,-9,O,8,9): %.2f (s)',...
    Time_in_quadrants(1),Time_in_quadrants(2),Time_in_quadrants(3),Time_in_quadrants(4));
title(title_str);

B = bwboundaries(Sliced_Maze);
for k = 1:length(B)
    plot(B{k}(:,2),B{k}(:,1),'w','LineWidth',2);
end

subplot(2,2,3); bar(1:20,Durations'); xlim([0 21]); set(gca,'XTick',1:20); set(gca,'XTickLabel',ROIs);
xlabel('ROI'); ylabel('Duration (s)');
title('Total duration of nose pokes');

N_NosePokes =zeros(20,1);
for i=1:9
    N_NosePokes(i) = length(NosePoke_durations{i+9});
end
N_NosePokes(10) = length(NosePoke_durations{20});
for i=11:19
    N_NosePokes(i) = length(NosePoke_durations{i-10});
end
N_NosePokes(20) = length(NosePoke_durations{19});

subplot(2,2,4); bar(1:20,N_NosePokes'); xlim([0 21]); set(gca,'XTick',1:20); set(gca,'XTickLabel',ROIs);
xlabel('ROI'); ylabel('Count');
title('Number of nose pokes');
analysis.ROIs = ROIs;
analysis.Durations = Durations;
analysis.N_NosePokes = N_NosePokes;
analysis.NosePoke_durations = NosePoke_durations;
analysis.NosePoke_timestamps = NosePoke_timestamps;
set(gcf,'Units','Normalized','Position',[0 0 1 1],'PaperPositionMode','auto','PaperSize',[14 14]);

folder_name = fileparts(abs_mv_path);
if(~exist([folder_name '/BarnesMaze_results'],'dir'))
    mkdir([folder_name '/BarnesMaze_results']);
end
[~,vidname] = fileparts(abs_mv_path);
imgfilename = [folder_name '/BarnesMaze_results/' vidname '_summary'];
print(gcf,'-dpdf',[imgfilename '.pdf']);
print(gcf,'-dtiff','-r300',[imgfilename '.tif']);
analysis.Eyes = Eyes;
analysis.COM = COM;
analysis.Info = Info;
analysis.L = L;
analysis.filename = Info.filename;
analysis.Icomposite = Icomposite;
analysis.Location = Location;
analysis.latency = latency;
analysis.dist_to_escape = dist_to_escape;
analysis.total_dist = total_dist;
analysis.errors = errors;
save([folder_name '/BarnesMaze_results/' vidname '.mat'],'analysis');
delete(hsum);
% disp(['Finished processing ' abs_mv_path]);
parfor_progress(0,fname,vidname);
try
    delete(hbar);
end

% Write results to a txt file

fid_nose = fopen([folder_name '/BarnesMaze_results/' vidname '.txt'],'w');
fprintf(fid_nose,'Filename \t Mouse Tag \t Latency to escape(s) \t Distance to escape (inch) \t Total Ambulation (inch) \t # of errors \t Time in quadrant 1 \t Time in quadrant 2 \t Time in quadrant 3 \t Time in quadrant 4\n');

try
    s = analysis;
    fprintf(fid_nose,'%s\t%s\t%.2f\t%.2f\t%.2f\t%d\t%.2f\t%.2f\t%.2f\t%.2f\n',s.Info.filename,s.Info.MouseTag,s.latency,s.dist_to_escape,s.total_dist,s.errors,s.Time_in_quadrants(1),s.Time_in_quadrants(2),s.Time_in_quadrants(3),s.Time_in_quadrants(4));
    
    % Output nosepokes by ROI in a separate file
    
    fprintf(fid_nose,'ROI \t Total nosepokes \t Duration of nosepokes \t time-stamp (duration)\n');
    for k=1:9
        fprintf(fid_nose,'%d\t%d\t%.2f\t',k,length(s.NosePoke_timestamps{k}),sum(s.NosePoke_durations{k}));
        for m=1:length(s.NosePoke_timestamps{k})
            fprintf(fid_nose,'%.1f (%.1f)\t',s.NosePoke_timestamps{k}(m),s.NosePoke_durations{k}(m));
        end
        fprintf(fid_nose,'\n');
    end
    fprintf(fid_nose,'Target\t%d\t%.2f\t',length(s.NosePoke_timestamps{20}),sum(s.NosePoke_durations{20}));
    for k=1:length(s.NosePoke_timestamps{20})
        fprintf(fid_nose,'%.1f (%.1f)\t',s.NosePoke_timestamps{20}(k),s.NosePoke_durations{20}(k));
    end
    fprintf(fid_nose,'\n');
    for k=18:-1:10
        fprintf(fid_nose,'%d\t%d\t%.2f\t',k-19,length(s.NosePoke_timestamps{k}),sum(s.NosePoke_durations{k}));
        for m=1:length(s.NosePoke_timestamps{k})
            fprintf(fid_nose,'%.1f (%.1f)\t',s.NosePoke_timestamps{k}(m),s.NosePoke_durations{k}(m));
        end
        fprintf(fid_nose,'\n');
    end
    fprintf(fid_nose,'Opposite\t%d\t%.2f\t',length(s.NosePoke_timestamps{19}),sum(s.NosePoke_durations{19}));
    for k=1:length(s.NosePoke_timestamps{19})
        fprintf(fid_nose,'%.1f (%.1f)\t',s.NosePoke_timestamps{19}(k),s.NosePoke_durations{19}(k));
    end
    fprintf(fid_nose,'\n');
    fclose(fid_nose);
end
