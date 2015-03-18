function analysis = YMaze(Info,varargin)
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
% disp(['Processing ' Info.filename]);
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
global cancel;
cancel = 0;
if(DISPLAY)
    h=figure;
    hax = axes('Units','pixels');
    uicontrol('Style', 'pushbutton', 'String', 'Cancel',...
        'Position', [20 20 50 20],...
        'Callback', {@pushbutton_callback});
end
%%
if(isfield(Info,'length') && ~isempty(Info.length))
    C = regionprops(Info.ROIs.Stem,'MajorAxisLength');
    px_per_inch = C(1).MajorAxisLength/Info.length;
else
    px_per_inch = 22;
end
frames = mmcount(Info.filename);
ROIs = Info.ROIs;
Maze = uint8(ROIs.Maze);
X = zeros(frames,1); Y = zeros(frames,1); Dsum = zeros(frames,1);
v = mmread(Info.filename,1);
Icomposite = zeros(size(v.frames.cdata,1),size(v.frames.cdata,2));
times = zeros(frames,1);
Location = zeros(frames,1); % 1 = LeftArm, 2 = RightArm, 3 = Stem
LeftArea = zeros(frames,1);
RightArea = zeros(frames,1);
StemArea = zeros(frames,1);

LeftBW = Info.ROIs.LeftArm;
RightBW = Info.ROIs.RightArm;
StemBW = Info.ROIs.Stem;
if(isfield(Info,'duration') && ~isempty(Info.duration))
    duration = Info.duration*60;
else
    duration = 5*60;
end

% Read ref frame
V = mmread(Info.filename,Info.ref_idx);
Gref = rgb2gray(V.frames.cdata).*Maze;
Info.start_idx = Info.start_idx+2;
% Read f frames at a time for speed
f = 100;
T = [Info.start_idx:f:frames frames];
disp(vidname);
fname = tempname(pwd);
parfor_progress(length(T),fname,vidname);
if(isfield(Info,'thresh') && ~isempty(Info.thresh))
    thresh = Info.thresh;
else
    thresh = [];
end
for k=1:length(T)-1
    if(cancel==1)
        delete(h);
        delete(hbar);
        return;
    end
    V = mmread(Info.filename,T(k):T(k+1)-1);
    n = length(V(end).frames);
    waitbar(T(k)/frames,hbar,sprintf('Processing %s\n%d %%',vidname,round(100*T(k)/frames)));
    set(findall(hbar,'type','text'),'Interpreter','none');
    for j=1:n
        if(cancel==1)
            delete(h);
            delete(hbar);
            return;
        end
        i = T(k)+j-1;
       
        
        if(V(end).times(j) > times(Info.start_idx)+duration)
            break;
        end
         times(i) = V(end).times(j);
        try
            %             if(mod(i-Info.start_idx,1000)==0)
            %                 disp(['     ' Info.filename ': ' num2str(i-Info.start_idx) ' of ' num2str(frames-Info.start_idx) ' frames processed.']);
            %             end
            G = rgb2gray(V(end).frames(j).cdata).*Maze;
            
            if(Info.ref_time~=0)
                D = imabsdiff(G,Gref);
                if(isempty(thresh))
                    
                    L = SegmentMouse(D>255*graythresh(D));
                else
                    L = SegmentMouse(D>thresh);
                end
            else
                if(isempty(thresh))
                    thresh = 7;
                end
                BW = G./mean(G(:))<thresh & G./mean(G(:)) >0;
                
                L = SegmentMouse(BW);
            end
            
            C = regionprops(L,'Centroid','Extrema');
            x = C(end).Centroid(1); y = C(end).Centroid(2);
            X(i) = x; Y(i) = y;
            Icomposite = Icomposite + L;
            
            % Determine where in the maze is the mouse using extrema
            % information
            Extrema = floor([C(end).Extrema]);
            Extrema_L = zeros(8,3);
            for z=1:8
                Extrema_L(z,1) = LeftBW(Extrema(z,2),Extrema(z,1));
                Extrema_L(z,2) = RightBW(Extrema(z,2),Extrema(z,1));
                Extrema_L(z,3) = StemBW(Extrema(z,2),Extrema(z,1));
            end
            if(LeftBW(floor(C.Centroid(2)),floor(C.Centroid(1))))
                Location(i) = 1;
            end
            if(RightBW(floor(C.Centroid(2)),floor(C.Centroid(1))))
                Location(i) = 2;
            end
            if(StemBW(floor(C.Centroid(2)),floor(C.Centroid(1))))
                Location(i) = 3;
            end
            % Area of the mouse in closed and open regions
            Cleft = regionprops(L.*LeftBW,'Area');
            Cright = regionprops(L.*RightBW,'Area');
            Cstem = regionprops(L.*StemBW,'Area');
            if(~isempty(Cleft))
                LeftArea(i) = Cleft(1).Area;
            end
            if(~isempty(Cright))
                RightArea(i) = Cright(1).Area;
            end
            if(~isempty(Cstem))
                StemArea(i) = Cstem(1).Area;
            end
            if(DISPLAY)
                imshow(V.frames(j).cdata,'Parent',hax);
                hold on
                plot(x,y,'ro','MarkerFaceColor','r');
                
                if(Location(i)==1)
                    B = bwboundaries(LeftBW);
                    for q=1:length(B)
                        plot(B{q}(:,2),B{q}(:,1),'b','LineWidth',4);
                    end
                elseif(Location(i)==2)
                    B = bwboundaries(RightBW);
                    for q=1:length(B)
                        plot(B{q}(:,2),B{q}(:,1),'b','LineWidth',4);
                    end
                elseif(Location(i)==3)
                    B = bwboundaries(StemBW);
                    for q=1:length(B)
                        plot(B{q}(:,2),B{q}(:,1),'b','LineWidth',4);
                    end
                end
                hold off
                title(['Elapsed time = ' num2str(floor(times(i)-times(Info.start_idx+1))) ' (s)']);
                pause(1e-3);
            end
            %         plot(x,y,'ro');
            %         pause(1e-3);
            %         drawnow;
            %         hold off;
        end
    end
    parfor_progress(-1,fname,vidname);
end
try
close(h);
end
%% Post process
Info.start_idx = find(times,1,'first');
end_idx = find(times,1,'last');
if(isempty(end_idx))
    end_idx = frames;
end
X = X(Info.start_idx:end_idx);
Y = Y(Info.start_idx:end_idx);
Location = Location(Info.start_idx:end_idx);

PathLength = zeros(length(X),1);
for i=2:length(X)
    PathLength(i) = Distance(X(i),Y(i),X(i-1),Y(i-1));
end
Ambulation = cumsum(PathLength)/px_per_inch;
f = createFit1(Info.start_idx:end_idx,times(Info.start_idx:end_idx));
fps = 1/f.p1;

%% Figure out how many transitions
% Convert to a string of letters
Transitions = '';
if(Location(1)==1)
    Transitions(end+1) = 'L';
elseif(Location(1)==2)
    Transitions(end+1) = 'R';
elseif(Location(1)==3)
    Transitions(end+1) = 'S';
elseif(Location(1)==0)
    Transitions(end+1) = 'N';
end
for i=2:length(Location)
    
    if(Location(i)==1 && Transitions(end)~='L')
        Transitions(end+1) = 'L';
    elseif(Location(i)==2 && Transitions(end)~='R')
        Transitions(end+1) = 'R';
    elseif(Location(i)==3 && Transitions(end) ~='S')
        Transitions(end+1) = 'S';
    elseif(Location(i)==0 && Transitions(end) ~= 'N')
        Transitions(end+1) = 'N';
    end
    
end


Pattern = Transitions;
Pattern(Transitions=='L') = 'L';
Pattern(Transitions=='R') = 'R';
Pattern(Transitions=='S') = 'S';

TimeLeft = sum(Location==1)/fps;
TimeRight = sum(Location==2)/fps;
TimeStem = sum(Location==3)/fps;
TimeNeutral = sum(Location==0)/fps;

Stem_Right = length(strfind(Transitions,'SNR')) + length(strfind(Transitions,'SR'));
Stem_Left = length(strfind(Transitions,'SNL')) + length(strfind(Transitions,'SL'));
Right_Left = length(strfind(Transitions,'RNL')) + length(strfind(Transitions,'RL'));
Left_Right = length(strfind(Transitions,'LNR')) + length(strfind(Transitions,'LR'));
Right_Stem = length(strfind(Transitions,'RNS')) + length(strfind(Transitions,'RS'));
Left_Stem = length(strfind(Transitions,'LNS')) + length(strfind(Transitions,'LS'));

FirstExit = min([find(Location==1,1,'first') find(Location==2,1,'first')]);
FirstExit = times(FirstExit+Info.start_idx)-times(Info.start_idx);

% Compute the number of transitons. Start at the 3rd position and compare
% if the previous two are different
SpontTrans = 0;
Pattern(Pattern=='N') = [];
for i=3:length(Pattern)
    if(length(unique(Pattern(i-2:i)))==3)
        SpontTrans = SpontTrans +1;
    end
end
%% Show ambulation in the maze

hsum=figure;
a1=subplot(2,3,1); subimage(Gref); axis image;

% X(X(:,1)==0) = NaN;
% Y(Y(:,1)==0) = NaN;
hold on
plot(a1,X(X~=0),Y(X~=0),'b')
title(Info.filename,'Interpreter','none','FontSize',14);
set(a1,'XTickLabel',[]); set(a1,'YTickLabel',[]);

a2 = subplot(2,3,2); imagesc((Icomposite/fps)); axis image; colorbar;
title('Time in maze (s)','FontSize',14);
set(a2,'XTickLabel',[]); set(a2,'YTickLabel',[]);
% a3_pos = get(a3,'Position');
% set(a3,'Position',[.5 .4838 1.1*a3_pos(3) 1.1*a3_pos(4)]);

a3 = subplot(2,3,3); plot(a3,times(Info.start_idx+1:end_idx),Ambulation(1:end-1));

xlabel( 'Time (s)' ,'FontSize',14);
ylabel( 'Ambulation, inches','FontSize',14 );
title(['Total distance = ' num2str(Ambulation(end)) ' (inches)'])

a4 = subplot(2,3,4:6); imagesc(Location');
set(a4,'TickLength',[0 0]);
a4pos = get(a4,'Position');
% set(a4,'Position',[a4pos(1) a4pos(2)-.1 a4pos(3) a4pos(4)]);
% Put tick marks at every 30 seconds
ticks = [];
for i=0:30:times(end-1)
    ticks = [ticks find(abs(i-times)<.1,1,'first')];
    
end
ticklabels = 0:30:times(end-1);
set(a4,'XTick',ticks);
set(a4,'XTickLabel',ticklabels);
set(a4,'YTickLabel',[])
xlabel('Time (s)');
colorbar;
set(colorbar,'YTick',[0 1 2 3]);
colorbar('TickLabels',[]);
summary = sprintf('Time to first arm entry: %.2f (s)\n%d Stem -> Left, %d Stem -> Right, %d Right -> Left, %d Right -> Stem, %d Left -> Right, %d Left -> Stem\nTime in Stem = %d (s), Time in Right Arm = %d (s), Time in Left Arm = %d (s), Time in neutral = %d (s)',...
    FirstExit,Stem_Left,Stem_Right,Right_Left,Right_Stem,Left_Right,Left_Stem,floor(TimeStem),floor(TimeRight),floor(TimeLeft),floor(TimeNeutral));
summary = sprintf('%s\nPattern: %s\nSpontaneous Transition: %d',summary,Pattern(Pattern~='N'),SpontTrans);

title(summary,'FontSize',16);



set(gcf,'Units','Normalized','Position',[0 0 1 1],'PaperPositionMode','auto','PaperSize',[14 14]);
[folder,file] = fileparts(Info.filename);
savefile = [folder '/Results/' file '_summary'];
if(~exist([folder '/Results'],'dir'))
    mkdir(folder,'Results');
end
set(gcf,'PaperPositionMode','auto')

print(gcf,savefile,'-dtiff','-r300');
delete(hsum);

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
analysis.Transitions = Transitions;
analysis.Stem_Left = Stem_Left;
analysis.Stem_Right = Stem_Right;
analysis.Right_Left = Right_Left;
analysis.Right_Stem = Right_Stem;
analysis.Left_Right = Left_Right;
analysis.Left_Stem = Left_Stem;
analysis.FirstExit = FirstExit;
analysis.TimeStem = TimeStem;
analysis.TimeLeft = TimeLeft;
analysis.TimeRight = TimeRight;
analysis.TimeNeutral = TimeNeutral;
analysis.Pattern = Pattern;
analysis.SpontaneousTransitions = SpontTrans;
% disp(['Finished processing ' Info.filename]);
parfor_progress(0,fname,vidname);
try
    delete(hbar);
end

% Output to a txt file
fid = fopen([folder '/Results/' file '.txt'],'w');

% Header
fprintf(fid,'File name\tTime to first arm entry (s)\tTime Left (s)\tTime Right (s)\tTime Stem (s)\tTime Neutral (s)\tTotal distance (inch)\tStem -> Right\tStem -> Left\tRight -> Left\tRight -> Stem\tLeft -> Right\tLeft -> Stem\tPattern\t# Spontaneous Transitions\n');

s = analysis;
fprintf(fid,'%s\t %f\t %f\t %f\t %f\t %f\t %f\t %d\t %d\t %d\t %d\t %d\t %d\t%s\t%d\n',s.Info.filename,s.FirstExit,s.TimeLeft,s.TimeRight,s.TimeStem,s.TimeNeutral,s.Ambulation(end),s.Stem_Right,s.Stem_Left,s.Right_Left,s.Right_Stem,s.Left_Right,s.Left_Stem,s.Pattern,s.SpontaneousTransitions);

fclose(fid);