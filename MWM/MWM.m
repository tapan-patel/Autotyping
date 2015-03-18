function analysis = MWM(Info,varargin)
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


abs_mv_path = Info.filename;
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
end_idx = Info.end_idx;
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
T = [start_idx+1:f:frames frames];
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
    fps = V.rate;
    try
        for j=1:n
            if(cancel==1)
                delete(h);
                delete(hbar);
                return;
            end
            i = T(k)+j-1;
            times(i) = V(end).times(j);
            if(i>end_idx)
                break;
            end
            
            %         if(mod(i-start_idx,1000)==0)
            %             disp(['     ' Info.filename ': ' num2str(i-start_idx) ' of ' num2str(frames-start_idx) ' frames processed.']);
            %         end
            
            I = rgb2gray(V.frames(j).cdata);
            
            D = imabsdiff(I,Bkg);
            D = imfill(D,'holes');
            D = D.*(surface);
            if(isfield(Info,'thresh') && ~isempty(Info.thresh))
                thresh = Info.thresh;
            else
                thresh = max([20 255*graythresh(D)]);
            end
            try
                L = SegmentMouse(D>thresh,D,1);
                
                C1 = regionprops(L,'Centroid');
                %         MouseCOM(i,:) = C1.Centroid;
                
                MouseCOM(i,:) = C1.Centroid;
                Icomposite = Icomposite + double(L);
                
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
start_idx = find(times,1,'first');

analysis.fps = fps;

analysis.filename = abs_mv_path;
analysis.duration = times(end_idx)-times(start_idx);
analysis.times = times;
analysis.Iref = Bkg;
Icomposite = Icomposite./fps;
analysis.Icomposite = Icomposite;

D = zeros(size(MouseCOM,1),1);
for i=start_idx+1:end_idx
    x1 = MouseCOM(i-1,1);
    y1 = MouseCOM(i-1,2);
    x2 = MouseCOM(i,1);
    y2 = MouseCOM(i,2);
    D(i) = sqrt( (x2-x1)^2 + (y2-y1)^2);
end
pathlength = sum(D);
C = regionprops(Info.ROIs.surface,'BoundingBox','MajorAxisLength');

% Convert from pixels to cm - user inputs maze diameter in cm
px_per_cm = C(end).MajorAxisLength/Info.dimensions_L;
pathlength = pathlength/px_per_cm; % Path length is now in units of cm
pathlength = pathlength/100; % Convert to units of meters
latency = times(end_idx)-times(start_idx); % Time to reach platform in seconds
swimspeed = pathlength/latency; % Average swim speed
analysis.latency = latency;
analysis.pathlength = pathlength;
analysis.swimspeed = swimspeed;
analysis.Info = Info;
%%
hsum=figure('Visible','on');
subplot(1,2,1); imshow(Iref); axis image
freezeColors;
title(sprintf('%s\nLatency to platform = %.2f (s), path-length = %.2f (meters), swim speed = %.2f (m/s)',abs_mv_path,latency, pathlength, swimspeed),'Interpreter','None');

hold all
plot(MouseCOM(start_idx:end_idx,1),MouseCOM(start_idx:end_idx,2),'k');
plot(MouseCOM(start_idx,1),MouseCOM(start_idx,2),'bo','MarkerFaceColor','b','MarkerSize',6);
plot(MouseCOM(end_idx,1),MouseCOM(end_idx,2),'bx','MarkerFaceColor','b','MarkerSize',12);
B = bwboundaries(Info.ROIs.surface);
for k=1:length(B)
    plot(B{k}(:,2),B{k}(:,1),'r','LineWidth',2)
end
B = bwboundaries(Info.ROIs.platform);
for k=1:length(B)
    plot(B{k}(:,2),B{k}(:,1),'g','LineWidth',2)
end
axis image

subplot(1,2,2);
imagesc(Icomposite); axis image; colormap('jet'); colorbar;drawnow;
hold on
B = bwboundaries(Info.ROIs.surface);
for k=1:length(B)
    plot(B{k}(:,2),B{k}(:,1),'w','LineWidth',2)
end
B = bwboundaries(Info.ROIs.platform);
for k=1:length(B)
    plot(B{k}(:,2),B{k}(:,1),'w','LineWidth',2)
end

set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
title(sprintf('tag# %s',Info.Tag),'Interpreter','none');
set(gcf,'Units','Normalized','Position',[0 0 1 1],'PaperPositionMode','auto','PaperSize',[14 14]);

folder_name = fileparts(abs_mv_path);
% If SOR_results directory does not exist, create it
if(~exist([folder_name '/MWM_results'],'dir'))
    mkdir([folder_name '/MWM_results']);
end
[~,vidname] = fileparts(abs_mv_path);
imgfilename = [folder_name '/MWM_results/' vidname '_summary'];
print(gcf,[imgfilename '.tif'],'-dtiff','-r300');
savefig(gcf,[imgfilename '.fig']);
close(hsum);

save([folder_name '/MWM_results/' vidname '.mat'],'analysis');
% disp(['Done processing ' abs_mv_path]);
% disp(['Summary figure generated to ' imgfilename '.tif']);
parfor_progress(0,fname,vidname);
try
    delete(hbar);
end

%% Write to txt file
fid = fopen([folder_name '/' vidname '_summary.txt'],'w');
fprintf(fid,'Filename \t Mouse Tag \t Latency (s) \t Path-length (m) \t Avg swim speed (m/s)\n' );

s = analysis;

fprintf(fid,'%s \t %s \t %.2f \t %.2f \t %.2f',s.filename,s.Info.Tag,s.latency,s.pathlength,s.swimspeed);
fprintf(fid,'\n');
fclose(fid);