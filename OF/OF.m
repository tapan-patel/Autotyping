function analysis = OF(Info,varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania
% Add mmread to path
if(isempty(which('mmread')))
    addpath('../mmread');
end
[~,vidname] = fileparts(Info.filename);
hbar = waitbar(0,sprintf('Processing %s\n0%%', vidname));
set(findall(hbar,'type','text'),'Interpreter','none');


% Take care of variable inputs
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
% Default duration is 600s
if(isfield(Info,'duration') && ~isempty(Info.duration))
    duration = Info.duration;
else
    duration = 600;
end
abs_mv_path = Info.filename;
% Default arena durations are 12x15 inches
if(isfield(Info,'dimensions_L') && isfield(Info,'dimensions_W') ...
        && ~isempty(Info.dimensions_L) && ~isempty(Info.dimensions_W))
    box_dim = [Info.dimensions_L Info.dimensions_W];
else
    box_dim = [12 15];
end
% Determine the number of frames in the video
if(isfield(Info,'frames') && ~isempty(Info.frames))
    frames = Info.frames;
else
    frames = mmcount(abs_mv_path);
    if(isnan(frames))
        vid = VideoReader(abs_mv_path);
        
        if(isempty(vid.NumberOfFrames))
            read(vid,inf);
        end
        
        frames = vid.NumberOfFrames;
    end
end
abs_mv_path = Info.filename;
start_idx = Info.start_idx;
% disp(['Processing ' abs_mv_path]);

if(isfield(Info,'ref_frame') && ~isempty(Info.ref_frame))
    Iref = Info.ref_frame;
    Bkg = Iref;
else
    Iref = EstimateBackground(abs_mv_path,frames,start_idx);
    Bkg = Iref;
end

Gref = Iref;
Icomposite = zeros(size(Gref));
Ibouts = Icomposite;
ROIs = Info.ROIs;
surface = imerode(uint8(ROIs.surface),ones(10));
MouseCOM = zeros(frames,2);
times = zeros(frames,1);
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
for k =1:length(T)-1
    if(cancel==1)
        delete(h);
        delete(hbar);
        return;
    end
    V = mmread(abs_mv_path,T(k):T(k+1)-1);
    n = length(V(end).frames);
    waitbar(T(k)/frames,hbar,sprintf('Processing %s\n%d %%',vidname,round(100*T(k)/frames)));
    set(findall(hbar,'type','text'),'Interpreter','none');
    try
        for j=1:n
            if(cancel==1)
                delete(h);
                delete(hbar);
                return;
            end
            i = T(k)+j-1;
            
            if(V(end).times(j) > (times(Info.start_idx)+duration))
                break;
            end
            %         if(mod(i-start_idx,1000)==0)
            %             disp(['     ' Info.filename ': ' num2str(i-start_idx) ' of ' num2str(frames-start_idx) ' frames processed.']);
            %         end
            times(i) = V(end).times(j);
            I = rgb2gray(V.frames(j).cdata);
            
            D = imabsdiff(I,Bkg);
            D = imfill(D,'holes');
            D = D.*(surface);
            if(isfield(Info,'thresh') && ~isempty(Info.thresh))
                thresh = Info.thresh;
            else
                thresh = 255*graythresh(D);
            end
            try
                L = SegmentMouse(D>thresh,D,1);
                Icomposite = Icomposite + L;
                C1 = regionprops(L,'Centroid');
                MouseCOM(i,:) = C1.Centroid;
            catch
                MouseCOM(i,:) = MouseCOM(i-1,:);
            end
            if(DISPLAY)
                imshow(I,'Parent',hax);
                hold on
                plot(MouseCOM(i,1),MouseCOM(i,2),'ro','MarkerFaceColor','r');
                title(['Elapsed time = ' num2str(floor(times(i)-times(start_idx+1))) ' (s)']);
                pause(1e-3);
                hold off
            end
        end
        parfor_progress(-1,fname,vidname);
    end
end
if(DISPLAY)
    close(h);
end
try
    parfor_progress(-1,fname,vidname);
end
start_idx = find(times,1,'first');
% Find the index of end time
end_idx = find(times,1,'last');
fitresult = createFit1(start_idx:end_idx,times(start_idx:end_idx)');
fps = 1/fitresult.p1;
analysis.fps = fps;


analysis.filename = abs_mv_path;
analysis.duration = times(end_idx)-times(start_idx);
analysis.times = times;
analysis.Iref = Bkg;
Icomposite = Icomposite./fps;
analysis.Icomposite = Icomposite;
if(isfield(Info,'perimeter') && ~isempty(Info.perimeter))
    periphery = Info.perimeter;
else
    periphery = 2.0; % 2 inches from the walls is the periphery
end

C = regionprops(Info.ROIs.surface,'BoundingBox');
box_dim = [Info.dimensions_L Info.dimensions_W];
px_per_inch = mean([C.BoundingBox(3)/box_dim(1) C.BoundingBox(4)/box_dim(2)]);
inner_BW = imerode(Info.ROIs.surface,ones(ceil(2*periphery*px_per_inch)));
outer_BW = Info.ROIs.surface - inner_BW;
% Assign the mouse to outer ring (1), or inner ring (2)
Location = single(ones(end_idx-start_idx+1,1));
for i=1:(end_idx-start_idx+1)
    if(floor(MouseCOM(i,2))~=0 && floor(MouseCOM(i,1))~=0)
        if(outer_BW(floor(MouseCOM(i,2)),floor(MouseCOM(i,1))))
            Location(i) = 1;
        elseif(inner_BW(floor(MouseCOM(i,2)),floor(MouseCOM(i,1))))
            Location(i) = 2;
        end
    end
end
% Determine the amount of time spent in each regions in 5minute intervals
% Videos should be either 10 or 30 mins long. Assuming that they are 10 min
% here

idx = floor(linspace(start_idx,end_idx,duration/(60*5)+1))-start_idx+1;

for i=1:length(idx)-1
    TimeOuter(1,i) = nnz(Location(idx(i):idx(i+1))==1)./fps;
    TimeInner(1,i) = nnz(Location(idx(i):idx(i+1))==2)./fps;
end
path_length = 0;
for i=start_idx+1:end_idx
    if(all(MouseCOM(i,:)>0 & MouseCOM(i-1,:)>0))
        delta = sqrt( (MouseCOM(i,1)-MouseCOM(i-1,1))^2 + (MouseCOM(i,2)-MouseCOM(i-1,2))^2);
        if(~isnan(delta))
            path_length = path_length + delta;
        end
    end
end
path_length = path_length/px_per_inch;
for i=1:length(idx)-1
    thigmotaxis(1,i) = TimeOuter(i)./(TimeOuter(i)+TimeInner(i));
end

%%
hsum=figure('Visible','on');
subplot(1,3,1); imshow(Iref); axis image
freezeColors;
title(abs_mv_path,'Interpreter','none');

hold all
plot(MouseCOM(start_idx:end_idx,1),MouseCOM(start_idx:end_idx,2),'k');
B = bwboundaries(outer_BW);
plot(B{1}(:,2),B{1}(:,1),'r','LineWidth',4)
B = bwboundaries(inner_BW);
plot(B{1}(:,2),B{1}(:,1),'r','LineWidth',4)

subplot(1,3,2);
C = regionprops(Info.ROIs.surface,'BoundingBox');
I1 = imcrop(Icomposite,C.BoundingBox);
imagesc(I1); axis image; colormap('jet'); colorbar;drawnow;
set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
title(sprintf('tag# %s',Info.Tag));
analysis.Outer = TimeOuter;
analysis.Inner = TimeInner;
analysis.Thigmotaxis = thigmotaxis;
analysis.TotalDistance = path_length;
analysis.MouseCOM = MouseCOM;
Motion = zeros(frames,1);
for i=start_idx+1:end_idx
    Motion(i) = norm(MouseCOM(i,:)-MouseCOM(i-1,:));
end
Motion = Motion./px_per_inch;
analysis.pathl = Motion;
analysis.Info = Info;
subplot(1,3,3);  plot(times(start_idx:end_idx)-times(start_idx),cumsum(analysis.pathl(start_idx:end_idx)),'b');
xlabel('Times (s)');
ylabel('Cumulative ambulation (inches)');

set(gcf,'Units','Normalized','Position',[0 0 1 1],'PaperPositionMode','auto','PaperSize',[14 14]);

folder_name = fileparts(abs_mv_path);
% If OF_results directory does not exist, create it
if(~exist([folder_name '/OF_results'],'dir'))
    mkdir([folder_name '/OF_results']);
end
[~,vidname] = fileparts(abs_mv_path);
imgfilename = [folder_name '/OF_results/' vidname '_summary'];
print(gcf,[imgfilename '.tif'],'-dtiff','-r300');
delete(hsum);

save([folder_name '/OF_results/' vidname '.mat'],'analysis');
% disp(['Done processing ' abs_mv_path]);
% disp(['Summary figure generated to ' imgfilename '.tif']);
parfor_progress(0,fname,vidname);
try
    delete(hbar);
end

intervals = Info.duration/(60*5);
% Output results to a txt file in /SOR_results directory
fid = fopen([folder_name '/OF_results/' vidname '.txt'],'w');
fprintf(fid,'Filename \t Mouse Tag \t Total Ambulation (inch)');
for i=1:intervals
    fprintf(fid,'\tTime in outer %i',i);
end
for i=1:intervals
    fprintf(fid,'\tTime in inner %i',i);
end
for i=1:intervals
    fprintf(fid,'\tThigmotaxis %i',i);
end
fprintf(fid,'\n');

s = analysis;
%         try
%         Ambulation = sum(s.PathLength);

fprintf(fid,'%s \t %s \t %.2f',s.filename,s.Info.Tag,s.TotalDistance);

for k=1:length(s.Outer)
    fprintf(fid,'\t%.2f',s.Outer(k));
end
for k=1:length(s.Inner)
    fprintf(fid,'\t%.2f',s.Inner(k));
end

for k=1:length(s.Thigmotaxis)
    fprintf(fid,'\t%.2f',s.Thigmotaxis(k));
end
fprintf(fid,'\n');
fclose(fid);
