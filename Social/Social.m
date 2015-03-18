function analysis = Social(Info,varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania

% Track the position of the mouse's head and compute how long it spends
% interacting with one of 2 objects.
% try
% Add mmread to path
if(isempty(which('mmread')))
    addpath('../mmread');
end
if(isempty(which('inpaint_nans')))
    addpath('../Inpaint_nans');
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
% disp(['Processing ' abs_mv_path]);

abs_mv_path = Info.filename;
skip1 = 0; skip2 = 0; % Skip the first or second 10 minute interval
if(Info.start_time1==0 && Info.end_time1 == 0)
    skip1 = 1;
end
if(Info.start_time2==0 && Info.end_time2 == 0)
    skip2 = 1;
end

start_idx1 = TimeToFrame(abs_mv_path,1,(Info.start_time1+5)*30,Info.start_time1);
end_idx1 = TimeToFrame(abs_mv_path,start_idx1,(Info.end_time1+5)*30,Info.end_time1);


start_idx2 = TimeToFrame(abs_mv_path,end_idx1,(Info.start_time2+5)*30,Info.start_time2);
end_idx2 = TimeToFrame(abs_mv_path,start_idx2,(Info.end_time2+5)*30,Info.end_time2);

% end_idx1 = start_idx1+500;
% end_idx2 = start_idx2 + 500;

frames = end_idx2;

Info.start_idx1 = start_idx1;
Info.end_idx1 = end_idx1;
Info.start_idx2 = start_idx2;
Info.end_idx2 = end_idx2;


px_per_inch_L = 0;
px_per_inch_R = 0;
magfactorL = 0;
magfactorR = 0;
ROIs = Info.ROIs;
if(isfield(Info,'box_W') && ~isempty(Info.box_W))
    box_dim(1) = Info.box_W;
else
    box_dim(1) = 10;
end
if(isfield(Info,'box_L') && ~isempty(Info.box_L))
    box_dim(2) = Info.box_L;
else
    box_dim(2) = 20;
end
TopMouse = Info.LeftMouse;
BottomMouse = Info.RightMouse;
if(TopMouse)
    C = regionprops(Info.ROIs.surface_top,'BoundingBox');
    px_per_inch_L = floor(mean([C.BoundingBox(3)/box_dim(1) C.BoundingBox(4)/box_dim(2)]));
    magfactorL = ceil(px_per_inch_L*.5);
    Icomposite_top1 = zeros(size(Info.ROIs.surface_top));
    Icomposite_top2 = zeros(size(Info.ROIs.surface_top));
    Ibouts_top1 = Icomposite_top1;
    Ibouts_top2 = Icomposite_top2;
    surface_top = uint8(ROIs.surface_top);
    TopCOM = zeros(end_idx2,2);
    
    BW_Top_Left1 = imdilate(imfill(ROIs.BWobject1,'holes'),strel('disk',px_per_inch_L,0));
    BW_Top_Left2 = imdilate(imfill(ROIs.BWobject3,'holes'),strel('disk',px_per_inch_L,0));
    BW_Top_Right1 = imdilate(imfill(ROIs.BWobject2,'holes'),strel('disk',px_per_inch_L,0));
    BW_Top_Right2 = imdilate(imfill(ROIs.BWobject4,'holes'),strel('disk',px_per_inch_L,0));
    
    Looking_TopLeft = false(frames,1);
    Looking_TopRight = false(frames,1);
    
    TopHead = single(zeros(frames,2));
    TopTail = single(zeros(frames,2));
    TopEyes = single(zeros(frames,2));
end

if(BottomMouse)
    C = regionprops(Info.ROIs.surface_bottom,'BoundingBox');
    px_per_inch_R = floor(mean([C.BoundingBox(3)/box_dim(1) C.BoundingBox(4)/box_dim(2)]));
    magfactorR = ceil(px_per_inch_R*.5);
    Icomposite_bottom1 = zeros(size(Info.ROIs.surface_bottom));
    Icomposite_bottom2 = zeros(size(Info.ROIs.surface_bottom));
    Ibouts_bottom1 = Icomposite_bottom1;
    Ibouts_bottom2 = Icomposite_bottom2;
    surface_bottom = uint8(ROIs.surface_bottom);
    BottomCOM = zeros(end_idx2,2);
    
    BW_Bottom_Left1 = imdilate(imfill(ROIs.BWobject5,'holes'),strel('disk',px_per_inch_R,0));
    BW_Bottom_Right1 = imdilate(imfill(ROIs.BWobject6,'holes'),strel('disk',px_per_inch_R,0));
    BW_Bottom_Left2 = imdilate(imfill(ROIs.BWobject7,'holes'),strel('disk',px_per_inch_R,0));
    BW_Bottom_Right2 = imdilate(imfill(ROIs.BWobject8,'holes'),strel('disk',px_per_inch_R,0));
    
    Looking_BottomLeft = false(frames,1);
    Looking_BottomRight = false(frames,1);
    
    BottomHead = single(zeros(frames,2));
    BottomTail = single(zeros(frames,2));
    BottomEyes = single(zeros(frames,2));
end

times = zeros(frames,1);
global cancel;
cancel = 0;
if(DISPLAY)
    h=figure;
    hax = axes('Units','pixels');
    uicontrol('Style', 'pushbutton', 'String', 'Cancel',...
        'Position', [20 20 50 20],...
        'Callback', {@pushbutton_callback});
end

if(~skip1)
    % Read f frames at a time for speed
    f = 200;
    T = [start_idx1:f:end_idx1 end_idx1];
    [~,vidname] = fileparts(abs_mv_path);
    disp([vidname ' (10'' - 20'')']);
    fname = tempname(pwd);
    parfor_progress(length(T),fname,vidname);
    
    % Need to determine the background within start and end frame range.
    % Randomly sample 500 frames and take the mode
    indices = randsample(end_idx1-start_idx1,min([100 end_idx1-start_idx1]))+start_idx1;
    indices = sort(indices);
    V = mmread(abs_mv_path,indices); V = V(end);
    A = zeros(V.height,V.width,length(V.frames),'uint8');
    for i=1:length(V.frames)
        A(:,:,i) = rgb2gray(V.frames(i).cdata);
    end
    Bkg1 = uint8(mode(double(A),3));
    % vid_out = VideoWriter('social_demo.avi');
    % open(vid_out);
    for k =1:length(T)-1
        if(cancel==1)
            delete(h);
            delete(hbar);
            return;
        end
        V = mmread(abs_mv_path,T(k):T(k+1)-1);
        n = length(V(end).frames);
        waitbar(T(k)/frames,hbar,sprintf('Processing %s (0 - 10min)\n%d %%',vidname,round(100*T(k)/end_idx1)));
        set(findall(hbar,'type','text'),'Interpreter','none');
        for j=1:n
            if(cancel==1)
                delete(h);
                delete(hbar);
                return;
            end
            i = T(k)+j-1;
            times(i) = V(end).times(j);
            
            %             if(mod(i-start_idx1,1000)==0)
            %                 disp(['     ' Info.filename ': ' num2str(i-start_idx1) ' of ' num2str(end_idx1-start_idx1) ' frames processed.']);
            %             end
            
            I = rgb2gray(V.frames(j).cdata);
            
            D = imabsdiff(I,Bkg1);
            D = imfill(D,'holes');
            if(DISPLAY)
                imshow(I,'Parent',hax);
                hold on
            end
            try
                if(TopMouse)
                    Dtop = D.*(surface_top);
                    top_thresh = 40;
                    Ltop = SegmentMouse(Dtop>top_thresh,BW_Top_Left1,BW_Top_Right1);
                    Icomposite_top1 = Icomposite_top1 + Ltop;
                    [xhead1, yhead1 , xtail1, ytail1,Vision1,COM1,mal] = GetHeadCoordinates(Ltop);
                    TopCOM(i,:) = [COM1(1) COM1(2)];
                    TopHead(i,:) = [xhead1 yhead1];
                    TopTail(i,:) = [xtail1 ytail1];
                    Vision1 = Vision1*magfactorL/norm(Vision1);
                    TopEyes(i,:) = Vision1;
                    
                    Looking_TopLeft(i) = IsLooking(xhead1,yhead1,Vision1,BW_Top_Left1,COM1);
                    Looking_TopRight(i) = IsLooking(xhead1,yhead1,Vision1,BW_Top_Right1,COM1);
                    if(Looking_TopLeft(i) || Looking_TopRight(i))
                        Ibouts_top1 = Ibouts_top1 + double(Ltop);
                    end
                    
                    if(DISPLAY)
                        plot(TopCOM(i,1),TopCOM(i,2),'ro');
                        if(Looking_TopLeft(i))
                            B = bwboundaries(BW_Top_Left1);
                            for q=1:length(B)
                                plot(B{q}(:,2),B{q}(:,1),'b');
                            end
                        end
                        if(Looking_TopRight(i))
                            
                            B = bwboundaries(BW_Top_Right1);
                            for q=1:length(B)
                                plot(B{q}(:,2),B{q}(:,1),'b');
                            end
                        end
                        pause(1e-3);
                    end
                end
            end
            try
                if(BottomMouse)
                    Dbottom = D.*(surface_bottom);
                    bottom_thresh = 40;
                    Lbottom = SegmentMouse(Dbottom>bottom_thresh,BW_Bottom_Left1,BW_Bottom_Right1);
                    Icomposite_bottom1 = Icomposite_bottom1 + Lbottom;
                    [xhead1, yhead1 , xtail1, ytail1,Vision1,COM1,mal] = GetHeadCoordinates(Lbottom);
                    BottomCOM(i,:) = [COM1(1) COM1(2)];
                    BottomHead(i,:) = [xhead1 yhead1];
                    BottomTail(i,:) = [xtail1 ytail1];
                    Vision1 = Vision1*magfactorL/norm(Vision1);
                    BottomEyes(i,:) = Vision1;
                    
                    Looking_BottomLeft(i) = IsLooking(xhead1,yhead1,Vision1,BW_Bottom_Left1,COM1);
                    Looking_BottomRight(i) = IsLooking(xhead1,yhead1,Vision1,BW_Bottom_Right1,COM1);
                    if(Looking_BottomLeft(i) || Looking_BottomRight(i))
                        Ibouts_bottom1 = Ibouts_bottom1 + double(Lbottom);
                    end
                    if(DISPLAY)
                        plot(BottomCOM(i,1),BottomCOM(i,2),'ro');
                        if(Looking_BottomLeft(i))
                            B = bwboundaries(BW_Bottom_Left1);
                            for q=1:length(B)
                                plot(B{q}(:,2),B{q}(:,1),'b');
                            end
                        end
                        if(Looking_BottomRight(i))
                            
                            B = bwboundaries(BW_Bottom_Right1);
                            for q=1:length(B)
                                plot(B{q}(:,2),B{q}(:,1),'b');
                            end
                        end
                        pause(1e-3);
                    end
                end
            end
        end
        parfor_progress(-1,fname,vidname);
    end
end
parfor_progress(0,fname,vidname);
%% Now focus on the second 10 minute interval
if(~skip2)
    f = 200;
    T = [start_idx2:f:end_idx2 end_idx2];
    [~,vidname] = fileparts(abs_mv_path);
    disp([vidname ' (10'' - 20'')']);
    fname = tempname(pwd);
    parfor_progress(length(T),fname,vidname);
    % Need to determine the background within start and end frame range.
    % Randomly sample 500 frames and take the mode
    indices = randsample(end_idx2-start_idx2,min([100 end_idx2-start_idx2]))+start_idx2;
    indices = sort(indices);
    V = mmread(abs_mv_path,indices); V = V(end);
    A = zeros(V.height,V.width,length(V.frames),'uint8');
    for i=1:length(V.frames)
        A(:,:,i) = rgb2gray(V.frames(i).cdata);
    end
    Bkg2 = uint8(mode(double(A),3));
    % vid_out = VideoWriter('social_demo.avi');
    % open(vid_out);
    
    for k =1:length(T)-1
        V = mmread(abs_mv_path,T(k):T(k+1)-1);
        n = length(V(end).frames);
        waitbar(T(k)/frames,hbar,sprintf('Processing %s (10 - 20min)\n%d %%',vidname,round(100*T(k)/end_idx2)));
        set(findall(hbar,'type','text'),'Interpreter','none');
        for j=1:n
            i = T(k)+j-1;
            times(i) = V(end).times(j);
            
            %             if(mod(i-start_idx2,1000)==0)
            %                 disp(['     ' Info.filename ': (10''-20'')' num2str(i-start_idx2) ' of ' num2str(end_idx2-start_idx2) ' frames processed.']);
            %             end
            
            I = rgb2gray(V.frames(j).cdata);
            
            D = imabsdiff(I,Bkg2);
            D = imfill(D,'holes');
            try
                if(TopMouse)
                    Dtop = D.*(surface_top);
                    top_thresh = 40;
                    Ltop = SegmentMouse(Dtop>top_thresh,BW_Top_Left2,BW_Top_Right2);
                    Icomposite_top2 = Icomposite_top2 + Ltop;
                    [xhead1, yhead1 , xtail1, ytail1,Vision1,COM1,mal] = GetHeadCoordinates(Ltop);
                    TopCOM(i,:) = [COM1(1) COM1(2)];
                    TopHead(i,:) = [xhead1 yhead1];
                    TopTail(i,:) = [xtail1 ytail1];
                    Vision1 = Vision1*magfactorL/norm(Vision1);
                    TopEyes(i,:) = Vision1;
                    
                    Looking_TopLeft(i) = IsLooking(xhead1,yhead1,Vision1,BW_Top_Left2,COM1);
                    Looking_TopRight(i) = IsLooking(xhead1,yhead1,Vision1,BW_Top_Right2,COM1);
                    if(Looking_TopLeft(i) || Looking_TopRight(i))
                        Ibouts_top2 = Ibouts_top2 + double(Ltop);
                    end
                    if(DISPLAY)
                        plot(TopCOM(i,1),TopCOM(i,2),'ro');
                        if(Looking_TopLeft(i))
                            B = bwboundaries(BW_Top_Left2);
                            for q=1:length(B)
                                plot(B{q}(:,2),B{q}(:,1),'b');
                            end
                        end
                        if(Looking_TopRight(i))
                            
                            B = bwboundaries(BW_Top_Right2);
                            for q=1:length(B)
                                plot(B{q}(:,2),B{q}(:,1),'b');
                            end
                        end
                        pause(1e-3);
                    end
                end
            end
            try
                if(BottomMouse)
                    
                    Dbottom = D.*(surface_bottom);
                    bottom_thresh = 40;
                    Lbottom = SegmentMouse(Dbottom>bottom_thresh,BW_Bottom_Left2,BW_Bottom_Right2);
                    Icomposite_bottom2 = Icomposite_bottom2 + Lbottom;
                    [xhead1, yhead1 , xtail1, ytail1,Vision1,COM1,mal] = GetHeadCoordinates(Lbottom);
                    BottomCOM(i,:) = [COM1(1) COM1(2)];
                    BottomHead(i,:) = [xhead1 yhead1];
                    BottomTail(i,:) = [xtail1 ytail1];
                    Vision1 = Vision1*magfactorL/norm(Vision1);
                    BottomEyes(i,:) = Vision1;
                    
                    Looking_BottomLeft(i) = IsLooking(xhead1,yhead1,Vision1,BW_Bottom_Left2,COM1);
                    Looking_BottomRight(i) = IsLooking(xhead1,yhead1,Vision1,BW_Bottom_Right2,COM1);
                    if(Looking_BottomLeft(i) || Looking_BottomRight(i))
                        Ibouts_bottom2 = Ibouts_bottom2 + double(Lbottom);
                    end
                    if(DISPLAY)
                        plot(BottomCOM(i,1),BottomCOM(i,2),'ro');
                        if(Looking_BottomLeft(i))
                            B = bwboundaries(BW_Bottom_Left2);
                            for q=1:length(B)
                                plot(B{q}(:,2),B{q}(:,1),'b');
                            end
                        end
                        if(Looking_BottomRight(i))
                            
                            B = bwboundaries(BW_Bottom_Right2);
                            for q=1:length(B)
                                plot(B{q}(:,2),B{q}(:,1),'b');
                            end
                        end
                        pause(1e-3);
                    end
                end
            end
        end
        parfor_progress(-1,fname,vidname);
    end
end
%%
fitresult = createFit1(start_idx1:end_idx1,times(start_idx1:end_idx1)');
fps = 1/fitresult.p1;
analysis.fps = fps;

%% Convert to unit of time

% if(Info.Objects)
if(TopMouse)
    analysis.Time_Top_Left1 = nnz(Looking_TopLeft(start_idx1:end_idx1))/fps;
    analysis.Time_Top_Left2 = nnz(Looking_TopLeft(start_idx2:end_idx2))/fps;
    
    analysis.Time_Top_Right1 = nnz(Looking_TopRight(start_idx1:end_idx1))/fps;
    analysis.Time_Top_Right2 = nnz(Looking_TopRight(start_idx2:end_idx2))/fps;
    
    analysis.Icomposite_top1 = Icomposite_top1./fps;
    analysis.Icomposite_top2 = Icomposite_top2./fps;
    analysis.Ibouts_top1 = Ibouts_top1./fps;
    analysis.Ibouts_top2 = Ibouts_top2./fps;
    % Apply Kalman filter to COM
    TopCOM = Kalman(TopCOM);
    
    analysis.TopCOM = TopCOM;
    
    analysis.Looking_TopLeft = Looking_TopLeft;
    analysis.Looking_TopRight = Looking_TopRight;
    analysis.TopHead = TopHead;
    analysis.TopEyes = TopEyes;
    analysis.TopTail = TopTail;
    
    
end
if(BottomMouse)
    analysis.Time_Bottom_Left1 = nnz(Looking_BottomLeft(start_idx1:end_idx1))/fps;
    analysis.Time_Bottom_Left2 = nnz(Looking_BottomLeft(start_idx2:end_idx2))/fps;
    
    analysis.Time_Bottom_Right1 = nnz(Looking_BottomRight(start_idx1:end_idx1))/fps;
    analysis.Time_Bottom_Right2 = nnz(Looking_BottomRight(start_idx2:end_idx2))/fps;
    
    analysis.Icomposite_bottom1 = Icomposite_bottom1./fps;
    analysis.Icomposite_bottom2 = Icomposite_bottom2./fps;
    
    analysis.Ibouts_bottom1 = Ibouts_bottom1./fps;
    analysis.Ibouts_bottom2 = Ibouts_bottom2./fps;
    
    BottomCOM = Kalman(BottomCOM);
    
    analysis.BottomCOM = BottomCOM;
    analysis.Looking_BottomLeft = Looking_BottomLeft;
    analysis.Looking_BottomRight = Looking_BottomRight;
    analysis.BottomHead = BottomHead;
    analysis.BottomEyes = BottomEyes;
    analysis.BottomTail = BottomTail;
end


% Save to an analysis struct
analysis.filename = abs_mv_path;

analysis.times = times;
analysis.start_idx1 = start_idx1;
analysis.end_idx1 = end_idx1;
analysis.start_idx2 = start_idx2;
analysis.end_idx2 = end_idx2;
analysis.Bkg1 = Bkg1;
analysis.Bkg2 = Bkg2;


% Make a summary figure, separate for top and bottom mice
if(TopMouse)
    Obj1COM = regionprops(BW_Top_Left1,'Centroid');
    Obj2COM = regionprops(BW_Top_Right1,'Centroid');
    
    Obj1COM2 = regionprops(BW_Top_Left2,'Centroid');
    Obj2COM2 = regionprops(BW_Top_Right2,'Centroid');
    
    
    hsum=figure;
    subplot(2,3,1); imagesc(Bkg1); axis image; colormap('gray');
    hold all
    
    plot(TopCOM(start_idx1+10:end_idx1-1,1),TopCOM(start_idx1+10:end_idx1-1,2),'b');
    text(Obj1COM(1).Centroid(1)-40,Obj1COM(1).Centroid(2),[num2str(analysis.Time_Top_Left1) ' s'],'BackgroundColor',[.7 .9 .7]);
    text(Obj2COM(1).Centroid(1)-40,Obj2COM(1).Centroid(2),[num2str(analysis.Time_Top_Right1) ' s'],'BackgroundColor',[.7 .9 .7]);
    
    title_str = sprintf('Mouse Tag: %s, first 10 minute interval', Info.LeftTag);
    title(title_str,'Interpreter','none');
    freezeColors
    
    subplot(2,3,2);
    C = regionprops(Info.ROIs.surface_top,'BoundingBox');
    I1 = imcrop(analysis.Icomposite_top1,C.BoundingBox);
    imagesc(I1,[0 max([max(analysis.Icomposite_top1(:)) max(analysis.Icomposite_top2(:))])]);
    axis image; colorbar; colormap('jet');
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    title('Overall time spent in the chambers, first 10 min interval');
    subplot(2,3,3);
    
    I1 = imcrop(analysis.Ibouts_top1,C.BoundingBox);
    imagesc(I1,[0 max([max(analysis.Ibouts_top1(:)) max(analysis.Ibouts_top2(:))])]); axis image; colorbar; colormap('jet');
    title('Interaction bouts during first 10 min interval');
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    
    subplot(2,3,4); imagesc(Bkg2); axis image; colormap('gray');
    
    hold all
    plot(TopCOM(start_idx2+10:end_idx2-1,1),TopCOM(start_idx2+10:end_idx2-1,2),'b');
    text(Obj1COM2(1).Centroid(1)-40,Obj1COM2(1).Centroid(2),[num2str(analysis.Time_Top_Left2) ' s'],'BackgroundColor',[.7 .9 .7]);
    text(Obj2COM2(1).Centroid(1)-40,Obj2COM2(1).Centroid(2),[num2str(analysis.Time_Top_Right2) ' s'],'BackgroundColor',[.7 .9 .7]);
    
    title_str = sprintf('Mouse Tag: %s, second 10 minute interval',Info.LeftTag);
    title(title_str,'Interpreter','none');
    freezeColors
    
    subplot(2,3,5);
    C = regionprops(Info.ROIs.surface_top,'BoundingBox');
    I1 = imcrop(analysis.Icomposite_top2,C.BoundingBox);
    imagesc(I1,[0 max([max(analysis.Icomposite_top1(:)) max(analysis.Icomposite_top2(:))])]);
    axis image; colorbar; colormap('jet');
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    title('Overall time spent in the chambers, second 10 min interval');
    subplot(2,3,6);
    I1 = imcrop(analysis.Ibouts_top2,C.BoundingBox);
    imagesc(I1,[0 max([max(analysis.Ibouts_top1(:)) max(analysis.Ibouts_top2(:))])]); axis image; colorbar; colormap('jet');
    title('Interaction bouts during second 10 min interval');
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    drawnow;
    set(gcf,'Units','Normalized','Position',[0 0 1 1],'PaperPositionMode','auto','PaperSize',[14 14]);
    
    folder_name = fileparts(abs_mv_path);
    % If SOR_results directory does not exist, create it
    if(~exist([folder_name '/SI_results'],'dir'))
        mkdir([folder_name '/SI_results']);
    end
    [~,vidname] = fileparts(abs_mv_path);
    imgfilename = [folder_name '/SI_results/' vidname '_top_summary'];
    print(gcf,[imgfilename '.tif'],'-dtiff','-r300');
    %     print(gcf,'-dpdf',[imgfilename '.pdf']);
    delete(hsum);
end
%% Now make a summary figure for the bottom mouse
if(BottomMouse)
    Obj1COM = regionprops(BW_Bottom_Left1,'Centroid');
    Obj2COM = regionprops(BW_Bottom_Right1,'Centroid');
    
    Obj1COM2 = regionprops(BW_Bottom_Left2,'Centroid');
    Obj2COM2 = regionprops(BW_Bottom_Right2,'Centroid');
    
    
    hsum=figure;
    
    subplot(2,3,1); imagesc(Bkg1); axis image; colormap('gray');
    hold all
    
    plot(BottomCOM(start_idx1+10:end_idx1-1,1),BottomCOM(start_idx1+10:end_idx1-1,2),'b');
    text(Obj1COM(1).Centroid(1)-40,Obj1COM(1).Centroid(2),[num2str(analysis.Time_Bottom_Left1) ' s'],'BackgroundColor',[.7 .9 .7]);
    text(Obj2COM(1).Centroid(1)-40,Obj2COM(1).Centroid(2),[num2str(analysis.Time_Bottom_Right1) ' s'],'BackgroundColor',[.7 .9 .7]);
    
    title_str = sprintf('Mouse Tag: %s, first 10 minute interval',Info.RightTag);
    title(title_str,'Interpreter','none');
    freezeColors
    
    subplot(2,3,2);
    C = regionprops(Info.ROIs.surface_bottom,'BoundingBox');
    I1 = imcrop(analysis.Icomposite_bottom1,C.BoundingBox);
    imagesc(I1,[0 max([max(analysis.Icomposite_bottom1(:)) max(analysis.Icomposite_bottom2(:))])]);
    axis image; colorbar; colormap('jet');
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    title('Overall time spent in the chambers, first 10 min interval');
    subplot(2,3,3);
    
    I1 = imcrop(analysis.Ibouts_bottom1,C.BoundingBox);
    imagesc(I1,[0 max([max(analysis.Ibouts_bottom1(:)) max(analysis.Ibouts_bottom2(:))])]); axis image; colorbar; colormap('jet');
    title('Interaction bouts during first 10 min interval');
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    
    
    
    subplot(2,3,4); imagesc(Bkg2); axis image; colormap('gray');
    
    hold all
    plot(BottomCOM(start_idx2+10:end_idx2-1,1),BottomCOM(start_idx2+10:end_idx2-1,2),'b');
    text(Obj1COM2(1).Centroid(1)-40,Obj1COM2(1).Centroid(2),[num2str(analysis.Time_Bottom_Left2) ' s'],'BackgroundColor',[.7 .9 .7]);
    text(Obj2COM2(1).Centroid(1)-40,Obj2COM2(1).Centroid(2),[num2str(analysis.Time_Bottom_Right2) ' s'],'BackgroundColor',[.7 .9 .7]);
    
    title_str = sprintf('Mouse Tag: %s, second 10 minute interval',Info.LeftTag);
    title(title_str,'Interpreter','none');
    freezeColors
    
    subplot(2,3,5);
    C = regionprops(Info.ROIs.surface_bottom,'BoundingBox');
    I1 = imcrop(analysis.Icomposite_bottom2,C.BoundingBox);
    imagesc(I1,[0 max([max(analysis.Icomposite_bottom1(:)) max(analysis.Icomposite_bottom2(:))])]);
    axis image; colorbar; colormap('jet');
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    title('Overall time spent in the chambers, second 10 min interval');
    subplot(2,3,6);
    
    I1 = imcrop(analysis.Ibouts_bottom2,C.BoundingBox);
    imagesc(I1,[0 max([max(analysis.Ibouts_bottom1(:)) max(analysis.Ibouts_bottom2(:))])]); axis image; colorbar; colormap('jet');
    title('Interaction bouts during second 10 min interval');
    set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
    drawnow;
    set(gcf,'Units','Normalized','Position',[0 0 1 1],'PaperPositionMode','auto','PaperSize',[14 14]);
    
    folder_name = fileparts(abs_mv_path);
    % If SOR_results directory does not exist, create it
    if(~exist([folder_name '/SI_results'],'dir'))
        mkdir([folder_name '/SI_results']);
    end
    [~,vidname] = fileparts(abs_mv_path);
    imgfilename = [folder_name '/SI_results/' vidname '_bottom_summary'];
    print(gcf,[imgfilename '.tif'],'-dtiff','-r300');
    %     print(gcf,'-dpdf',[imgfilename '.pdf']);
    delete(hsum);
end
analysis.Info = Info;
%% Total distance travelled
if(TopMouse)
    Path_length_top = zeros(end_idx2,1);
    for i=start_idx1:end_idx1-1
        Path_length_top(i) = Distance(TopCOM(i,1),TopCOM(i,2),TopCOM(i+1,1), TopCOM(i+1,2))*px_per_inch_L;
    end
    for i=start_idx2:end_idx2-1
        Path_length_top(i) = Distance(TopCOM(i,1),TopCOM(i,2),TopCOM(i+1,1), TopCOM(i+1,2))*px_per_inch_L;
    end
    
    analysis.Distance_top1 = sum(Path_length_top(start_idx1:end_idx1));
    analysis.Distance_top2 = sum(Path_length_top(start_idx2:end_idx2));
end

if(BottomMouse)
    Path_length_bottom = zeros(end_idx2,1);
    for i=start_idx1:end_idx1-1
        Path_length_bottom(i) = Distance(BottomCOM(i,1),BottomCOM(i,2),BottomCOM(i+1,1), BottomCOM(i+1,2))*px_per_inch_R;
    end
    for i=start_idx2:end_idx2-1
        Path_length_bottom(i) = Distance(BottomCOM(i,1),BottomCOM(i,2),BottomCOM(i+1,1), BottomCOM(i+1,2))*px_per_inch_R;
    end
    
    analysis.Distance_bottom1 = sum(Path_length_bottom(start_idx1:end_idx1));
    analysis.Distance_bottom2 = sum(Path_length_bottom(start_idx2:end_idx2));
end
%% Time spent in each of the chambers

if(TopMouse)
    if(~isfield(Info.ROIs,'left_chamber_top') || ~isfield(Info.ROIs,'right_chamber_top') || ...
            isempty(Info.ROIs.left_chamber_top) || isempty(Info.ROIs.right_chamber_top))
        
        % Dilate the middle chamber to ensure surface-middle yields left and
        % right
        se = strel('line',20,90);
        BW_Top_MiddleChamber = imdilate(Info.ROIs.middle_chamber_top,se);
        BW = Info.ROIs.surface_top-BW_Top_MiddleChamber;
        BW(BW<0) = 0;
        L = bwlabel(BW);
        BW_Top_LeftChamber = L==1;
        BW_Top_RightChamber = L==2;
    else
        BW_Top_LeftChamber = Info.ROIs.left_chamber_top;
        BW_Top_RightChamber = Info.ROIs.right_chamber_top;
        BW_Top_MiddleChamber = logical(Info.ROIs.surface_top - BW_Top_LeftChamber - BW_Top_RightChamber);
    end
    cntr_left = 0; cntr_right = 0; cntr_middle = 0;
    for i=start_idx1:end_idx1-1
        try
            if(BW_Top_LeftChamber(floor(TopCOM(i,2)),floor(TopCOM(i,1))))
                cntr_left = cntr_left + 1;
            elseif(BW_Top_MiddleChamber(floor(TopCOM(i,2)),floor(TopCOM(i,1))))
                cntr_middle = cntr_middle + 1;
            elseif(BW_Top_RightChamber(floor(TopCOM(i,2)),floor(TopCOM(i,1))))
                cntr_right = cntr_right + 1;
            end
        end
    end
    analysis.Time_Top_LeftChamber1 = cntr_left/fps;
    analysis.Time_Top_RightChamber1 = cntr_right/fps;
    analysis.Time_Top_MiddleChamber1 = cntr_middle/fps;
    
    cntr_left = 0; cntr_right = 0; cntr_middle = 0;
    for i=start_idx2:end_idx2-1
        try
            if(BW_Top_LeftChamber(floor(TopCOM(i,2)),floor(TopCOM(i,1))))
                cntr_left = cntr_left + 1;
            elseif(BW_Top_MiddleChamber(floor(TopCOM(i,2)),floor(TopCOM(i,1))))
                cntr_middle = cntr_middle + 1;
            elseif(BW_Top_RightChamber(floor(TopCOM(i,2)),floor(TopCOM(i,1))))
                cntr_right = cntr_right + 1;
            end
        end
    end
    analysis.Time_Top_LeftChamber2 = cntr_left/fps;
    analysis.Time_Top_RightChamber2 = cntr_right/fps;
    analysis.Time_Top_MiddleChamber2 = cntr_middle/fps;
end

if(BottomMouse)
    if(~isfield(Info.ROIs,'left_chamber_bottom') || ~isfield(Info.ROIs,'right_chamber_bottom') || ...
            isempty(Info.ROIs.left_chamber_bottom) || isempty(Info.ROIs.right_chamber_bottom))
        
        % Dilate the middle chamber to ensure surface-middle yields left and
        % right
        se = strel('line',20,90);
        BW_Bottom_MiddleChamber = imdilate(Info.ROIs.middle_chamber_bottom,se);
        BW = Info.ROIs.surface_bottom-BW_Bottom_MiddleChamber;
        BW(BW<0) = 0;
        L = bwlabel(BW);
        BW_Bottom_LeftChamber = L==1;
        BW_Bottom_RightChamber = L==2;
    else
        BW_Bottom_LeftChamber = Info.ROIs.left_chamber_bottom;
        BW_Bottom_RightChamber = Info.ROIs.right_chamber_bottom;
        BW_Bottom_MiddleChamber = logical(Info.ROIs.surface_bottom - BW_Bottom_LeftChamber - BW_Bottom_RightChamber);
    end
    cntr_left = 0; cntr_right = 0; cntr_middle = 0;
    for i=start_idx1:end_idx1-1
        try
            if(BW_Bottom_LeftChamber(floor(BottomCOM(i,2)),floor(BottomCOM(i,1))))
                cntr_left = cntr_left + 1;
            elseif(BW_Bottom_MiddleChamber(floor(BottomCOM(i,2)),floor(BottomCOM(i,1))))
                cntr_middle = cntr_middle + 1;
            elseif(BW_Bottom_RightChamber(floor(BottomCOM(i,2)),floor(BottomCOM(i,1))))
                cntr_right = cntr_right + 1;
            end
        end
    end
    analysis.Time_Bottom_LeftChamber1 = cntr_left/fps;
    analysis.Time_Bottom_RightChamber1 = cntr_right/fps;
    analysis.Time_Bottom_MiddleChamber1 = cntr_middle/fps;
    
    cntr_left = 0; cntr_right = 0; cntr_middle = 0;
    for i=start_idx2:end_idx2-1
        try
            if(BW_Bottom_LeftChamber(floor(BottomCOM(i,2)),floor(BottomCOM(i,1))))
                cntr_left = cntr_left + 1;
            elseif(BW_Bottom_MiddleChamber(floor(BottomCOM(i,2)),floor(BottomCOM(i,1))))
                cntr_middle = cntr_middle + 1;
            elseif(BW_Bottom_RightChamber(floor(BottomCOM(i,2)),floor(BottomCOM(i,1))))
                cntr_right = cntr_right + 1;
            end
        end
    end
    analysis.Time_Bottom_LeftChamber2 = cntr_left/fps;
    analysis.Time_Bottom_RightChamber2 = cntr_right/fps;
    analysis.Time_Bottom_MiddleChamber2 = cntr_middle/fps;
end
%% Compute open-field parameters

% First figure out conversion from pixels to inches: box is 12x15 inch
% periphery = 2; % 1.5inch from the walls is the periphery
% figure

% if(Info.LeftMouse && ~isempty(Info.LeftTag))
%     C = regionprops(Info.ROIs.surface_left,'BoundingBox');
%     px_per_inch_L = mean([C.BoundingBox(3)/12 C.BoundingBox(4)/15]);
%     center_BW_L = imerode(Info.ROIs.surface_left,ones(ceil(2*periphery*px_per_inch_L)));
%     periphery_BW_L = Info.ROIs.surface_left - center_BW_L;
%     % Corners: 1 - top left, 2 - top right, 3 - bottom left, 4 - bottom right
%     ul = zeros(4,2);
%     ul(1,:) = [floor(C.BoundingBox(1)) floor(C.BoundingBox(2))];
%     ul(2,:) = [floor(C.BoundingBox(1)+C.BoundingBox(3)-periphery*px_per_inch_L) floor(C.BoundingBox(2))];
%     ul(3,:) = [floor(C.BoundingBox(1)) floor(C.BoundingBox(2)+C.BoundingBox(4)-periphery*px_per_inch_L)];
%     ul(4,:) = [floor(C.BoundingBox(1)+C.BoundingBox(3)-periphery*px_per_inch_L) floor(C.BoundingBox(2)+C.BoundingBox(4)-periphery*px_per_inch_L)];
%     for i=1:4
%         Corners_L(i).BW = false(size(Info.ROIs.surface_left));
%         for j=ul(i,1):floor((ul(i,1)+periphery*px_per_inch_L))
%             for k=ul(i,2):floor((ul(i,2)+periphery*px_per_inch_L))
%                 Corners_L(i).BW(k,j) = 1;
%             end
%         end
%     end
%     % Show the boundaries
%
%     B = bwboundaries(Info.ROIs.surface_left);
%     plot(B{1}(:,2),B{1}(:,1),'b','LineWidth',4)
%     B = bwboundaries(center_BW_L);
%     plot(B{1}(:,2),B{1}(:,1),'r','LineWidth',4)
%     for i=1:4
%         B = bwboundaries(Corners_L(i).BW);
%         plot(B{1}(:,2),B{1}(:,1),'g','LineWidth',4)
%     end
%     % Plot the mouse's trajectory
%     x = Mouse1COM(start_idx:end,1); y = Mouse1COM(start_idx:end,2);
%     plot(x(x~=0),y(y~=0),'k');
%
%     % Compute the amount of time spent in corners, center and periphery
%     [TimeSitting, TimeCorners, TimeOuter, TimeCenter,TimeInner,path_length,thigmotaxis,~,TimeSitting_in_corner,Motion]...
%         = OpenField_L(Mouse1COM,start_idx,frames,Info,fps,Tail1,duration,box_dim);
%     analysis.LeftCorner1Time = max(Icomposite(logical(Corners_L(1).BW)));
%     analysis.LeftCorner2Time = max(Icomposite(logical(Corners_L(2).BW)));
%     analysis.LeftCorner3Time = max(Icomposite(logical(Corners_L(3).BW)));
%     analysis.LeftCorner4Time = max(Icomposite(logical(Corners_L(4).BW)));
%
%     analysis.LeftCorners = TimeCorners;
%     analysis.LeftSitting = TimeSitting;
%
%     analysis.LeftOuter = TimeOuter;
%     analysis.LeftCenter = TimeCenter;
%     analysis.LeftInner = TimeInner;
%     analysis.LeftSitting_in_corner = TimeSitting_in_corner;
%     analysis.LeftThigmotaxis = thigmotaxis;
%     analysis.Left_pathl = Motion;
%     analysis.LeftTotalDistance = path_length;
%
% end


%%

save([folder_name '/SI_results/' vidname '.mat'],'analysis');
% if(Info.LeftObjects || Info.RightObjects)
%     WriteTiffStack(analysis);
% end
% catch
%     cprintf('*red','%s not run. ERROR\n',Info.filename);
%
% end
parfor_progress(0,fname,vidname);
try
    delete(hbar);
end
try
    delete(h);
end
fid = fopen([folder_name '/SI_results/' vidname '.txt'],'w');
fprintf(fid,'Filename \t Mouse Tag \t Left cylinder interaction time (0-10min) (s) \t Right cylinder interaction time (0-10min) (s) \t Left chamber time (0-10min) (s) \t Right chamber time (0-10min) (s) \t Middle chamber time (0-10min) (s) \t Total distance (0-10min) \t Left cylinder interaction time (10-20min) (s) \t Right cylinder interaction time (10-20min) (s) \t Left chamber time (10-20min) (s) \t Right chamber time (10-20min) (s) \t Middle chamber time (10-20min) (s) \t Total distance (10-20min)\n');


s = analysis;
try
    if(s.Info.LeftMouse)
        if(isfield(s.Info,'Novel') && ~isempty(s.Info.Novel))
            Novel = zeros(8,1);
            for m=1:length(s.Info.Novel)
                Novel(m) = s.Info.Novel;
            end
            s.Info.Novel = Novel;
            
            if(s.Info.Novel(1))
                LeftTime1 = sprintf('%.2f**',s.Time_Top_Left1);
            else
                LeftTime1 = sprintf('%.2f',s.Time_Top_Left1);
            end
            if(s.Info.Novel(2))
                RightTime1 = sprintf('%.2f**',s.Time_Top_Right1);
            else
                RightTime1 = sprintf('%.2f',s.Time_Top_Right1);
            end
            if(s.Info.Novel(3))
                LeftTime2 = sprintf('%.2f**',s.Time_Top_Left2);
            else
                LeftTime2 = sprintf('%.2f',s.Time_Top_Left2);
            end
            if(s.Info.Novel(4))
                RightTime2 = sprintf('%.2f**',s.Time_Top_Right2);
            else
                RightTime2 = sprintf('%.2f',s.Time_Top_Right2);
            end
            fprintf(fid,'%s \t %s \t %s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \t %s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \n',...
                s.filename, s.Info.LeftTag, LeftTime1, RightTime1,s.Time_Top_LeftChamber1,s.Time_Top_RightChamber1,s.Time_Top_MiddleChamber1,...
                s.Distance_top1, LeftTime2, RightTime2, s.Time_Top_LeftChamber2,s.Time_Top_RightChamber2,s.Time_Top_MiddleChamber2,s.Distance_top2);
        else
            fprintf(fid,'%s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \n',...
                s.filename, s.Info.LeftTag, s.Time_Top_Left1, s.Time_Top_Right1,s.Time_Top_LeftChamber1,s.Time_Top_RightChamber1,s.Time_Top_MiddleChamber1,...
                s.Distance_top1, s.Time_Top_Left2, s.Time_Top_Right2, s.Time_Top_LeftChamber2,s.Time_Top_RightChamber2,s.Time_Top_MiddleChamber2,s.Distance_top2);
        end
    end
end
try
    if(s.Info.RightMouse)
        if(isfield(s.Info,'Novel') && ~isempty(s.Info.Novel))
            Novel = zeros(8,1);
            for m=1:length(s.Info.Novel)
                Novel(m) = s.Info.Novel;
            end
            s.Info.Novel = Novel;
            if(s.Info.Novel(5))
                LeftTime1 = sprintf('%.2f**',s.Time_Bottom_Left1);
            else
                LeftTime1 = sprintf('%.2f',s.Time_Bottom_Left1);
            end
            if(s.Info.Novel(6))
                RightTime1 = sprintf('%.2f**',s.Time_Bottom_Right1);
            else
                RightTime1 = sprintf('%.2f',s.Time_Bottom_Right1);
            end
            if(s.Info.Novel(7))
                LeftTime2 = sprintf('%.2f**',s.Time_Bottom_Left2);
            else
                LeftTime2 = sprintf('%.2f',s.Time_Bottom_Left2);
            end
            if(s.Info.Novel(8))
                RightTime2 = sprintf('%.2f**',s.Time_Bottom_Right2);
            else
                RightTime2 = sprintf('%.2f',s.Time_Bottom_Right2);
            end
            fprintf(fid,'%s \t %s \t %s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \t %s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \n',...
                s.filename, s.Info.RightTag, LeftTime1, RightTime1,s.Time_Bottom_LeftChamber1,s.Time_Bottom_RightChamber1,s.Time_Bottom_MiddleChamber1,...
                s.Distance_bottom1, LeftTime2, RightTime2, s.Time_Bottom_LeftChamber2,s.Time_Bottom_RightChamber2,s.Time_Bottom_MiddleChamber2,s.Distance_bottom2);
        else
            fprintf(fid,'%s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \n',...
                s.filename, s.Info.RightTag, s.Time_Bottom_Left1, s.Time_Bottom_Right1,s.Time_Bottom_LeftChamber1,s.Time_Bottom_RightChamber1,s.Time_Bottom_MiddleChamber1,...
                s.Distance_bottom1, s.Time_Bottom_Left2, s.Time_Bottom_Right2, s.Time_Bottom_LeftChamber2,s.Time_Bottom_RightChamber2,s.Time_Bottom_MiddleChamber2,s.Distance_bottom2);
        end
    end
end

fclose(fid);