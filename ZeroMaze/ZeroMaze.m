function analysis = ZeroMaze(Info,varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania

% Fields in Info: filename, start_idx, ref_idx, ROIs.Open1, ROIs.Open2,
% ROIs.Closed1, ROIs.Closed2, ROIs.Maze. Go through the videos frame-by-frame, segment
% the mouse, compute centroid and store its coordinates. Keep a composite
% image as well for visual depiction.
warning off
% if(~matlabpool('size'))
%     matlabpool open
% end
disp(['Processing ' Info.filename]);
[~,vidname] = fileparts(Info.filename);
hbar = waitbar(0,sprintf('Processing %s\n0%%',vidname));
set(findall(hbar,'type','text'),'Interpreter','none');
% Add mmread to path
if(isempty(which('mmread')))
    addpath('../mmread');
end
% [~,vidname] = fileparts(abs_mv_path);
% disp(vidname);
% fname = tempname;
% parfor_progress(length(T),fname,vidname);


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
%%
if(isfield(Info,'diameter') && ~isempty(Info.diameter))
    diameter = Info.diameter/2.54; % input from gui is in cm..convert to inches
else
    diameter = 55/2.54;
end
C = regionprops(Info.ROIs.inner_maze,'MajorAxisLength');
px_per_inch = ceil(C(1).MajorAxisLength/diameter);
try
    frames = Info.frames;
catch
    frames = mmcount(Info.filename);
end
ROIs = Info.ROIs;
Maze = uint8(ROIs.Maze);
X = zeros(frames,1); Y = zeros(frames,2);
v = mmread(Info.filename,1);
Icomposite = zeros(size(v.frames.cdata,1),size(v.frames.cdata,2));
times = zeros(frames,1);
Location = zeros(frames,1);
OpenArea = zeros(frames,1);
CloseArea = zeros(frames,1);

CloseBW1 = Info.ROIs.Closed1;
CloseBW2 = Info.ROIs.Closed2;
OpenBW1 = Info.ROIs.Open1;
OpenBW2 = Info.ROIs.Open2;

% Read ref frame
try
    Gref = (Info.ref_frame).*Maze;
catch
    V = mmread(Info.filename,Info.ref_idx);
    Gref = rgb2gray(V.frames.cdata).*Maze;
end

Info.start_idx = Info.start_idx+2;
if(isfield(Info,'thresh') && ~isempty(Info.thresh))
    thresh = Info.thresh; % User specified a threshold to use
else
    Info.thresh = []; % User wants to use automated threshold
end
global cancel;
cancel = 0;
if(DISPLAY)
    h=figure;
    hax = axes('Units','pixels');
    uicontrol('Style', 'pushbutton', 'String', 'Cancel',...
        'Position', [20 20 50 20],...
        'Callback', {@pushbutton_callback});
end
if(isfield(Info,'duration') && ~isempty(Info.duration))
    duration = Info.duration*60;
else
    duration = 5*60;
end
for i=Info.start_idx:frames
    if(cancel==1)
        delete(h);
        delete(hbar);
        return;
    end
    if(~mod(i,1e2))
        disp([Info.filename ': ' num2str(i) ' of ' num2str(frames) ' processed.']);
        waitbar(i/frames,hbar,sprintf('Processing %s\n%d %%',vidname,round(100*i/frames)));
        set(findall(hbar,'type','text'),'Interpreter','none');
    end
    try
        
        v = mmread(Info.filename,i);
        v = v(end);
        G = rgb2gray(v(end).frames.cdata).*Maze;
        
        % Stop processing if exceed experiment duration
        if(v(end).times > times(Info.start_idx)+duration)
            break;
        end
        times(i) = v(end).times;
        % If the user specified a threshold use it, otherwise compute the
        % optimal threshold
         D = imabsdiff(G,Gref);
        if(isempty(Info.thresh))
            L = SegmentMouse(D>min([50 255*graythresh(D)]));
        else
              L = SegmentMouse(D>thresh);
        end
%         if(Info.ref_time~=0)
%             D = imabsdiff(G,Gref);
%             if(isempty(thresh))
%                 
%                 L = SegmentMouse(D>[min([50 255*graythresh(D)]));
%             else
%                 L = SegmentMouse(D>thresh);
%             end
%         else
%             if(isempty(thresh))
%                 thresh = 2;
%             end
%             BW = G./mean(G(:))<thresh & G./mean(G(:)) >0;
%             %         [~,c] = kmeans(double(D(:)),2,'start',[10;100]);
%             L = SegmentMouse(BW);
%         end
        C = regionprops(L,'Centroid','Extrema');
        x = C(end).Centroid(1); y = C(end).Centroid(2);
        X(i) = x; Y(i) = y;
        Icomposite = Icomposite + L;
        
        % Determine where in the maze is the mouse
        Extrema = floor([C(end).Extrema]);
        Extrema_L = zeros(8,4);
        for z=1:8
            Extrema_L(z,1) = OpenBW1(Extrema(z,2),Extrema(z,1));
            Extrema_L(z,2) = CloseBW1(Extrema(z,2),Extrema(z,1));
            Extrema_L(z,3) = OpenBW2(Extrema(z,2),Extrema(z,1));
            Extrema_L(z,4) = CloseBW2(Extrema(z,2),Extrema(z,1));
            
        end
        % Open1 = 1, Close1 = 2, Open2 = 3, Close2 = 4
        if(sum(Extrema_L(:,1))>7)
            Location(i) = 1;
        elseif(sum(Extrema_L(:,2))>4)
            Location(i) = 2;
        elseif(sum(Extrema_L(:,3))>7)
            Location(i) = 3;
        elseif(sum(Extrema_L(:,4))>4)
            Location(i) = 4;
        else
            MasterBW = OpenBW1 + 2*CloseBW1 + 3*OpenBW2 + 4*CloseBW2;
            Location(i) = MasterBW(floor(y),floor(x));
        end
        
        
        % Area of the mouse in closed and open regions
        Cclose = regionprops(L.*CloseBW1,'Area');
        Copen = regionprops(L.*OpenBW1,'Area');
        if(~isempty(Cclose))
            CloseArea(i) = Cclose(1).Area;
        end
        if(~isempty(Copen))
            OpenArea(i) = Copen(1).Area;
        end
        %     end
        if(DISPLAY)
            imshow(G,'Parent',hax);
            hold on
            plot(x,y,'ro','MarkerFaceColor','r');
            %             b = bwboundaries(L);
            if(Location(i)==1)
                B = bwboundaries(OpenBW1);
                for q=1:length(B)
                    plot(B{q}(:,2),B{q}(:,1),'b','LineWidth',4);
                end
            elseif(Location(i)==2)
                B = bwboundaries(CloseBW1);
                for q=1:length(B)
                    plot(B{q}(:,2),B{q}(:,1),'b','LineWidth',4);
                end
            elseif(Location(i)==3)
                B = bwboundaries(OpenBW2);
                for q=1:length(B)
                    plot(B{q}(:,2),B{q}(:,1),'b','LineWidth',4);
                end
            elseif(Location(i)==4)
                B = bwboundaries(CloseBW2);
                for q=1:length(B)
                    plot(B{q}(:,2),B{q}(:,1),'b','LineWidth',4);
                end
            end
            hold off
            title(['Elapsed time = ' num2str(floor(times(i)-times(Info.start_idx))) ' (s)']);
            pause(1e-3);
            
        end
      
    end
end
try
close(h);
end
%% Use the duration field to determine how much of the video to process
t_begin = times(Info.start_idx);
end_idx = find(times,1,'last');
if(isempty(end_idx))
    end_idx = frames;
end
X = X(Info.start_idx:end_idx);
Y = Y(Info.start_idx:end_idx);
CloseArea = CloseArea(Info.start_idx:end_idx);
OpenArea = OpenArea(Info.start_idx:end_idx);
times = times(Info.start_idx:end_idx)-times(Info.start_idx);
% % Location = Location(Info.start_idx:end_idx);
% thresh = min([max(CloseArea)*.1 350]);
% Location = CloseArea<thresh;
PathLength = zeros(length(X),1);
for i=2:length(X)
    PathLength(i) = Distance(X(i),Y(i),X(i-1),Y(i-1));
end
Ambulation = cumsum(PathLength)/px_per_inch;
f = createFit1(1:length(times),times');
fps = 1/f.p1;

%% Figure out how many closed to open and open to closed entries made
% Open1 = 1, Close1 = 2, Open2 = 3, Close2 = 4
Location = Location(Info.start_idx:end_idx);
TimeOpen1 = sum(Location==1)/fps;
TimeClosed1 = sum(Location==2)/fps;
TimeOpen2 = sum(Location==3)/fps;
TimeClosed2 = sum(Location==4)/fps;

Location_tmp = Location==1 | Location==3;
L = bwlabel(Location_tmp);
CO = max(L);
L = bwlabel(~Location_tmp);
OC = max(L);

idx1 = find(Location==1,1,'first');
idx2 = find(Location==3,1,'first');
if(isempty(idx1))
    idx1 = length(Location);
end
if(isempty(idx2))
    idx2 = length(Location);
end
TimeFirstExit = times(min([idx1 idx2]));

%% Risk assessment behavior - time spent assessing whether to go into the
%% open region, while most of the body is in the closed region
Boundary1 = imdilate(Info.ROIs.Closed1,strel(ones(px_per_inch*2)))-Info.ROIs.Closed1;
Boundary2 = imdilate(Info.ROIs.Closed2,strel(ones(px_per_inch*2)))-Info.ROIs.Closed2;

% Find the max value in the 4 boundaries -
[r,c] = size(Gref);

LeftRA= Icomposite.*double(Boundary1);
f1 = max(max(LeftRA(1:floor(r/2),:)));
f2 = max(max(LeftRA(floor(r/2):end,:)));

RightRA= Icomposite.*double(Boundary2);
f3 = max(max(RightRA(1:floor(r/2),:)));
f4 = max(max(RightRA(floor(r/2):end,:)));

RiskAssessment = [f1/fps f2/fps f3/fps f4/fps];


fitresult = createFit1(times,Ambulation);

%% Show ambulation in the maze

V = mmread(Info.filename,Info.ref_idx);
hsum=figure;
a1=subplot(2,3,1); subimage(V(end).frames.cdata); axis image;

X(X==0) = NaN;
Y(Y==0) = NaN;
hold on
plot(a1,X,Y)
title(Info.filename,'Interpreter','none','FontSize',14);
set(a1,'XTickLabel',[]); set(a1,'YTickLabel',[]);

a2 = subplot(2,3,2); imagesc(uint16(Icomposite/fps)); axis image; 
colormap('jet');colorbar;
title('Time spent in maze (s)','FontSize',14);
set(a2,'XTickLabel',[]); set(a2,'YTickLabel',[]);
% a3_pos = get(a3,'Position');
% set(a3,'Position',[.5 .4838 1.1*a3_pos(3) 1.1*a3_pos(4)]);

a3 = subplot(2,3,3); plot(a3,times,Ambulation);
hold on
plot(fitresult);
equation = ['Average speed = ' num2str(fitresult.p1) ' second^-1'];
legend(equation, 'Location', 'Best' );
xlabel( 'Time (s)' ,'FontSize',14);
ylabel( 'Ambulation','FontSize',14 );

L = repmat(Location',300,1);
L(L==2 | L==4) = 0;
a4 = subplot(2,3,4:6); subimage(L);
set(a4,'TickLength',[0 0]);
a4pos = get(a4,'Position');
% set(a4,'Position',[a4pos(1) a4pos(2)-.1 a4pos(3) a4pos(4)]);
% Put tick marks at every 30 seconds
ticks = [];
for i=0:30:times(end)
    ticks = [ticks find(abs(i-times)<.1,1,'first')];
    
end
ticklabels = 0:30:times(end);
set(a4,'XTick',ticks);
set(a4,'XTickLabel',ticklabels);
set(a4,'YTickLabel',[])
xlabel('Time (s)');
summary = sprintf('Black = closed, white = open.\nTime to first exit: %.2f (s), # of closed to open transitions: %d, # of open to closed transitions: %d.\nClosed: %.1f%%, Open: %.1f%%, Risk Assessment: %.1f%%.',...
    TimeFirstExit,CO,OC,100*(TimeClosed1+TimeClosed2)/times(end), 100*(TimeOpen1+TimeOpen2)/times(end),100*sum(RiskAssessment)/times(end));
title(summary,'FontSize',14);
set(gcf,'Units','Normalized','Position',[0 0 1 1],'PaperPositionMode','auto','PaperSize',[14 14]);

a2 = subplot(2,3,2); imagesc(uint16(Icomposite/fps)); axis image; 
colormap('jet');colorbar;
title('Time spent in maze (s)','FontSize',14);
set(a2,'XTickLabel',[]); set(a2,'YTickLabel',[]);
[folder,file] = fileparts(Info.filename);
savefile = [folder '/Results/' file '_summary'];
if(~exist([folder '/Results'],'dir'))
    mkdir(folder,'Results');
end
print(gcf,savefile,'-dtiff','-r300');


close(hsum);

%% Put results into a struct
analysis.Info = Info;
analysis.times = times;
analysis.PathLenth = PathLength;
analysis.Ambulation = Ambulation;
analysis.X = X;
analysis.Y = Y;
analysis.fps = fps;
analysis.Icomposite = Icomposite;
analysis.Location = Location;
analysis.RiskAssessment = RiskAssessment;
analysis.TotalRA = sum(RiskAssessment);
analysis.TimeOpen1 = TimeOpen1;
analysis.TimeClosed1 = TimeClosed1;
analysis.TimeOpen2 = TimeOpen2;
analysis.TimeClosed2 = TimeClosed2;

analysis.CO = CO;
analysis.OC = OC;
analysis.Speed = fitresult.p1;
analysis.TotalDistance = Ambulation(end);
analysis.OpenArea = OpenArea;
analysis.CloseArea = CloseArea;

analysis.TimeFirstExit = TimeFirstExit;

save([folder '/Results/' file '.mat'],'analysis');
disp(['Finished processing ' Info.filename]);
disp(['Summary figure saved to ' savefile '.tif']);
% parfor_progress(0,fname,vidname);
try
    delete(hbar);
end
fid = fopen([folder '/Results/' file '.txt'],'w');

% Header
fprintf(fid,'File name\tMouse Tag\tTime to first exit (s)\tTotal Close\t Total Open\tTime Closed1 (s)\tTime Closed2 (s)\t Time Open1 (s) \tTime Open2 (s)\tRisk Assessment\tTotal distance (inch)\tAverage speed (inch/s)\tOpen-to-Close transitions\tClose-to-open transitions\tComplexity\n');

s = analysis;
c = kolmogorov(s.Location);
fprintf(fid,'%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%d\t%d\n',s.Info.filename,s.Info.Tag,s.TimeFirstExit,s.TimeClosed1+s.TimeClosed2, s.TimeOpen1+s.TimeOpen2,s.TimeClosed1,s.TimeClosed2,s.TimeOpen1,s.TimeOpen2,s.TotalRA,s.Ambulation(end),s.Speed,s.OC,s.CO,c);

fclose(fid);