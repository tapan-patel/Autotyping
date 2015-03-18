classdef CROIEditor < handle
    %% CROIEditor
    %
    % A Class with a convenient user interface to define multiple region of
    % interest (ROI) on a given image.
    % All the imroi tools (freehand, circle, rectangle, polygon) can be used
    % to define these region(s).
    %
    % Loading and storing of previously defined ROI masks to and from files
    % is easily done via the UI toolbar.
    %
    % Multiple regions are labeled using the connected component labeling
    % method (using the MATLAB built-in bwlabel function).
    
    %%
    events
        MaskDefined % thrown when "apply" button is hit, listen to this event
        % to get the ROI information (obj.getROIData)
    end
    
    properties
        image    % image to work on, obj.image = theImageToWorkOn
        label    % input label
        roi      % the generated ROI mask (logical)
        labels   % Connected component labens (multi ROI)
        number   % how many ROIs there are
        
        figh = 300; % initial figure height - your image is scaled to fit.
        % On change of this the window gets resized
        buttons;
    end
    
    properties(Access=private)
        % UI stuff
        guifig    % mainwindow
        imax    % holds working area
        roiax   % holds roid preview image
        imag    % image to work on
        roifig  % roi image
        tl      % userinfo bar
        
        
        figw      % initial window height, this is calculated on load
        hwar = 2.1;  % aspect ratio
        
        % Class stuff
        loadmask  % mask loaded from file
        mask      % mask defined by shapes
        current      %  which shape is selected
        shapes; % holds all the shapes to define the mask
        radius
        % load/save information
        filename
        pathname
        background_defined = 0;
        background_coordinates = [0 0];
    end
    
    %% Public Methods
    methods
        
        function this = CROIEditor(theImage,theL)
            % constructor
            
            this.figw = this.figh*this.hwar;
            
            % invoke the UI window
            this.createWindow;
            
            % load the image
            if nargin > 0
                this.image = imadjust(theImage);
                this.label = theL;
                
                this.newROI; % delete stuff
                
                this.loadmask = theL;
                % Fill in shapes with ellipses
                C = regionprops(theL,'BoundingBox');
                this.shapes = cell(numel(C),1);
                for i=1:numel(C)
                    this.shapes{i} = imellipse(this.imax,C(i).BoundingBox);
                    set(this.shapes{i},'Tag',['imsel_', num2str(i)]);
                end
                this.updateROI;
                set(this.tl,'String',['Current: ' this.filename],'Visible','on','BackgroundColor','g');
                
            else
                this.image = ones(100,100);
            end
            
            % predefine class variables
            this.current = 1;
           
            this.filename = 'mymask'; % default filename
            this.pathname = pwd;      % current directory
            this.radius = 35;
        end
        
        function delete(this)
            % destructor
            % Make sure Apply was clicked.
            
            delete(this.guifig);
            
        end
        
        function set.image(this,theImage)
            % set method for image. uses grayscale images for region selection
            if size(theImage,3) == 3
                this.image = im2double(rgb2gray(theImage));
            elseif size(theImage,3) == 1
                this.image = im2double(theImage);
            else
                error('Unknown Image size?');
            end
            this.resetImages;
            this.resizeWindow;
        end
        
        function set.figh(this,height)
            this.figh = height;
            this.figw = this.figh*this.hwar;
            this.resizeWindow;
        end
        
        function [roi, bkg_coords] = getROIData(this,varargin)
            % retrieve ROI Data
            % Create a label matrix using the shapes so that touching
            % shapes do not get merged
            this.mask = zeros(size(this.image)) ;
            for i=1:numel(this.shapes)
                mask = this.shapes{i}.createMask(this.imag);
                this.mask(mask) = 0;
                
                this.mask = this.mask + i*this.shapes{i}.createMask(this.imag);
                
            end
            this.roi = this.mask;
            roi = this.roi;
            
            bkg_coords = this.background_coordinates;
        end
    end
    
    %% private used methods
    methods(Access=private)
        % general functions -----------------------------------------------
        function resetImages(this)
            this.newROI;
            
            % load images
            this.imag = imshow(this.image,'parent',this.imax);
            this.roifig = imshow(this.image,'parent',this.roiax);
            
            % set masks to blank
            this.loadmask = zeros(size(this.image));
        end
        
        function updateROI(this, a)
            set(this.tl,'String','ROI not saved/applied','Visible','on','BackgroundColor',[255 182 193]./256);
            this.mask = zeros(size(this.image)) ;
            for i=1:numel(this.shapes)
                this.mask = this.mask + this.shapes{i}.createMask(this.imag);
                this.mask = logical(this.mask);
            end
            set(this.roifig,'CData',(this.image.*this.mask));
        end
        
        function newShapeCreated(this)
            set(this.shapes{end},'Tag',sprintf('imsel_%.f',numel(this.shapes)));
            this.shapes{end}.addNewPositionCallback(@this.updateROI);
            this.updateROI;
        end
        
        % CALLBACK FUNCTIONS
        % window/figure
        function winpressed(this,h,e,type)
            switch type
                case 'up'
                    SelObj = get(gco,'Parent');
                    Tag = get(SelObj,'Tag');
                    if and(~isempty(SelObj),strfind(Tag,'imsel_'))
                        this.current = str2double(Tag(7:end));
                        for i=1:numel(this.shapes)
                            if i==this.current
                                setColor(this.shapes{i},'red');
                            else
                                setColor(this.shapes{i},'blue');
                            end
                        end
                    end
            end
        end
        
        function closefig(this,h,e)
            this.background_defined = 1;
            % Make sure a background ROI is defined
            if(~this.background_defined)
                msgbox('Background ROI is not defined. Please draw an ROI over a region devoid of cells');
            else
                choice = questdlg('Really quit? Did you click Apply to save your segmentation?');
                switch choice
                    case 'Yes'
                        delete(this);
                    case 'No'
                        uicontrol(this.buttons(6));
                    case 'Cancel'
                        uicontrol(this.buttons(6));
                end
            end
        end;
        
        % button callbacks ------------------------------------------------
        function keyPress(this,h,e)
            
            switch e.Key
                case 'a'
                    set(this.buttons(1),'Selected','on')
                    polyclick(this,h,e);
                    
                case 'e'
                    set(this.buttons(2),'Selected','on')
                    elliclick(this,h,e);
                case 'f'
                    set(this.buttons(3),'Selected','on')
                    freeclick(this,h,e);
                case 'u'
                    set(this.buttons(4),'Selected','on')
                    rectclick(this,h,e);
                case 'd'
                    set(this.buttons(5),'Selected','on')
                    deleteclick(this,h,e);
            end
        end
        
        function setradius(this,h,e)
            this.radius = str2num(get(h,'String'));
        end
        function polyclick(this, h,e)
            
            %             this.shapes{end+1} = impoly(this.imax);
            axes(this.imax);
            [x,y] = ginput(1);
            %                this.shapes{end+1} = imellipse(this.imax,[x-(this.radius-8) y-(this.radius-10) this.radius this.radius]);
            this.shapes{end+1} = imellipse(this.imax,[x-(this.radius/2) y-(this.radius/2+2) this.radius this.radius]);
            this.newShapeCreated; % add tag, and callback to new shape
            set(this.buttons(1),'Selected','off')
        end
        
        function elliclick(this, h,e)
            
            this.shapes{end+1} = imfreehand(this.imax);
            this.newShapeCreated; % add tag, and callback to new shape
            set(this.buttons(2),'Selected','off')
        end
        
        function freeclick(this,h,e)
            % Change to defining a background ROI
            axes(this.imax);
            hel = imellipse(this.imax);
            
            this.shapes{end+1} = hel;
            this.newShapeCreated; % add tag, and callback to new shape
            this.background_defined = 1;
            this.background_coordinates = regionprops(this.shapes{end}.createMask,'Centroid');
            
            set(this.buttons(3),'Selected','off')
        end
        
        function rectclick(this,h,e)
            
            %             this.shapes{end+1} = imrect(this.imax);
            %             this.newShapeCreated; % add tag, and callback to new shape
            %             set(this.buttons(4),'Selected','off')
            this.updateROI;
        end
        
        function deleteclick(this,h,e)
            
            % delete currently selected shape
            this.current = this.current(end);
            if ~isempty(this.current) && this.current > 0
                
                n = findobj(this.imax, 'Tag',['imsel_', num2str(this.current)]);
                delete(n);
                % renumbering of this.shapes: (e.g. if 3 deleted: 4=>3, 5=>4,...
                for i=this.current+1:numel(this.shapes)
                    set(this.shapes{i},'Tag',['imsel_', num2str(i-1)]);
                end
                this.shapes(this.current)=[];
                this.current = numel(this.shapes);
                this.updateROI;
            else
                disp('first select a shape to remove');
            end
            set(this.buttons(5),'Selected','off')
        end
        
        function applyclick(this, h, e, varargin)
            this.background_defined = 1;
            if(~this.background_defined)
                msgbox('Background ROI not defined. Please draw an ROI over a region devoid of cells');
            else
                set(this.tl,'String','ROI applied','Visible','on','BackgroundColor','g');
                this.roi = this.mask;
                [this.labels, this.number] = bwlabel(this.mask);
                
                if~(nargin > 3 && strcmp(varargin{1},'nopreview'))
                    % preview window
                    preview = figure('MenuBar','none','Resize','off',...
                        'Toolbar','none','Name','Created ROI', ...
                        'NumberTitle','off','Color','white',...
                        'position',[0 0 300 300]);
                    movegui(preview,'center');
                    
                    imshow(label2rgb(this.labels),'InitialMagnification','fit');
                    title({'This is your labeled ROI', ...
                        ['you have ', num2str(this.number), ' independent region(s)']});
                    uicontrol('style','pushbutton',...
                        'string','OK!','Callback','close(gcf)');
                end
                notify(this, 'MaskDefined');
            end
        end
        
        function saveROI(this, h,e)
            % save Mask to File
            try
                [this.filename, this.pathname] = uiputfile('*.mask','Save Mask as',this.filename);
                % Create a label matrix using the shapes so that touching
                % shapes do not get merged
                this.mask = zeros(size(this.image)) ;
                for i=1:numel(this.shapes)
                    this.mask = this.mask + i*this.shapes{i}.createMask(this.imag);
                    
                end
                
                logicmask = this.mask;
                bkg_coordinates = this.background_coordinates;
                save([this.pathname, this.filename],'logicmask','bkg_coordinates','-mat');
                set(this.tl,'String',['ROI saved: ' this.filename],'Visible','on','BackgroundColor','g');
            catch
                % aborted
            end
        end
        
        function openROI(this, h,e)
            % load Mask from File
            this.newROI; % delete stuff
            [this.filename,this.pathname,~] = uigetfile('','Select segmentation file - .mat or .tif');
            try
                if(strcmp(this.filename(end-2:end),'mat'))
                    b = load([this.pathname,this.filename],'-mat');
                    b.logicmask = b.BW;
                    if(exist('b','var') && isfield(b,'bkg_coords'))
                        this.background_defined = 1;
                        this.background_coordinates = b.bkg_coords;
                    end
                else
                    I = imread([this.pathname,this.filename]);
                    b.logicmask = logical(I);
                end
                if size(b.logicmask)~=size(this.image)
                    set(this.tl,'String',['Size not matching! ' this.filename],'Visible','on','BackgroundColor','r');
                else
                    this.loadmask = b.logicmask;
                    % Fill in shapes with ellipses
                    C = regionprops(b.logicmask,'BoundingBox');
                    this.shapes = cell(numel(C),1);
                    for i=1:numel(C)
                        this.shapes{i} = imellipse(this.imax,C(i).BoundingBox);
                        set(this.shapes{i},'Tag',['imsel_', num2str(i)]);
                    end
                    this.updateROI;
                    set(this.tl,'String',['Current: ' this.filename],'Visible','on','BackgroundColor','g');
                end
            catch
                % aborted
            end
        end
        
        function newROI(this, h,e)
            this.mask = zeros(size(this.image));
            this.loadmask = zeros(size(this.image));
            % remove all the this.shapes
            for i=1:numel(this.shapes)
                delete(this.shapes{i});
            end
            this.current = 1; % defines the currently selected shape - start with 1
            this.shapes = {}; % reset shape holder
            this.updateROI;
        end
        
        % UI FUNCTIONS ----------------------------------------------------
        function createWindow(this, w, h)
            
            this.guifig=figure('MenuBar','none','Resize','on','Toolbar','none','Name','ROI Editor', ...
                'NumberTitle','off','Color','white', 'units','pixels','position',[0 0 this.figw this.figh],...
                'CloseRequestFcn',@this.closefig, 'visible','off','KeyPressFcn',@(h,e)this.keyPress(h,e));
            
            % buttons
            buttons = gobjects(0);
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Auto Circle',...
                'units','normalized',...
                'Position',[0.01 0.8 0.1 0.15], ...
                'Callback',@(h,e)this.polyclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Freehand',...
                'units','normalized',...
                'Position',[0.01 0.65 0.15 0.15],...
                'Callback',@(h,e)this.elliclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Ellipse ROI',...
                'units','normalized',...
                'Position',[0.01 0.5 0.15 0.15],...
                'Callback',@(h,e)this.freeclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Update',...
                'units','normalized',...
                'Position',[0.01 0.35 0.15 0.15],...
                'Callback',@(h,e)this.rectclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Delete',...
                'units','normalized',...
                'Position',[0.01 0.2 0.15 0.15],...
                'Callback',@(h,e)this.deleteclick(h,e));
            buttons(end+1) = uicontrol('Parent',this.guifig,'String','Apply',...
                'units','normalized',...
                'Position',[0.01 0.05 0.15 0.15],...
                'Callback',@(h,e)this.applyclick(h,e));
            
            buttons(end+1) = uicontrol('Parent',this.guifig,'style','edit',...
                'string',num2str(35),...
                'units','normalized',...
                'Position',[0.12 0.85 0.05 0.05], ...
                'Callback',@(h,e)this.setradius(h,e));
            this.buttons = buttons;
            % axes
            this.imax = axes('parent',this.guifig,'units','normalized','position',[0.18 0.07 0.4 0.87]);
            this.roiax = axes('parent',this.guifig,'units','normalized','position',[0.59 0.07 0.4 0.87]);
            linkaxes([this.imax this.roiax]);
            
            % create toolbar
            this.createToolbar(this.guifig);
            
            % add listeners
            set(this.guifig,'WindowButtonDownFcn',@(h,e)this.winpressed(h,e,'down'));
            set(this.guifig,'WindowButtonUpFcn',@(h,e)this.winpressed(h,e,'up')) ;
            
            % axis titles
            uicontrol('tag','txtimax','style','text','string','Working Area','units','normalized',...
                'position',[0.18 0.95 0.4 0.05], ...
                'BackgroundColor','w');
            uicontrol('tag','txtroiax','style','text','string','ROI Preview','units','normalized',...
                'position',[0.59 0.95 0.4 0.05], ...
                'BackgroundColor','w');
            
            % file load info
            this.tl = uicontrol('tag','txtfileinfo','style','text','string','','units','normalized',...
                'position',[0.18 0.01 0.81 0.05], ...
                'BackgroundColor','g','visible','off');
        end
        
        function resizeWindow(this)
            [h,w]=size(this.image);
            f = w/h;
            this.figw = this.figh*this.hwar*f;
            
            set(this.guifig,'position',[0 0 this.figw this.figh]);
            movegui(this.guifig,'center');
            set(this.guifig,'visible','on');
            
        end
        
        function tb=createToolbar(this, fig)
            tb = uitoolbar('parent',fig);
            
            hpt=gobjects(0);
            hpt(end+1) = uipushtool(tb,'CData',localLoadIconCData('file_new.png'),...
                'TooltipString','New ROI',...
                'ClickedCallback',...
                @this.newROI);
            hpt(end+1) = uipushtool(tb,'CData',localLoadIconCData('file_open.png'),...
                'TooltipString','Open ROI',...
                'ClickedCallback',...
                @this.openROI);
            hpt(end+1) = uipushtool(tb,'CData',localLoadIconCData('file_save.png'),...
                'TooltipString','Save ROI',...
                'ClickedCallback',...
                @this.saveROI);
            
            %---
            hpt(end+1) = uitoggletool(tb,'CData',localLoadIconCData('tool_zoom_in.png'),...
                'TooltipString','Zoom In',...
                'ClickedCallback',...
                'putdowntext(''zoomin'',gcbo)',...
                'Separator','on');
            hpt(end+1) = uitoggletool(tb,'CData',localLoadIconCData('tool_zoom_out.png'),...
                'TooltipString','Zoom Out',...
                'ClickedCallback',...
                'putdowntext(''zoomout'',gcbo)');
            hpt(end+1) = uitoggletool(tb,'CData',localLoadIconCData('tool_hand.png'),...
                'TooltipString','Pan',...
                'ClickedCallback',...
                'putdowntext(''pan'',gcbo)');
        end
    end  % end private methods
end

% this is copied from matlabs uitoolfactory.m, to load the icons for the toolbar
function cdata = localLoadIconCData(filename)
% Loads CData from the icon files (PNG, GIF or MAT) in toolbox/matlab/icons.
% filename = info.icon;

% Load cdata from *.gif file
persistent ICONROOT
if isempty(ICONROOT)
    ICONROOT = fullfile(matlabroot,'toolbox','matlab','icons',filesep);
end

if length(filename)>3 && strncmp(filename(end-3:end),'.gif',4)
    [cdata,map] = imread([ICONROOT,filename]);
    % Set all white (1,1,1) colors to be transparent (nan)
    ind = map(:,1)+map(:,2)+map(:,3)==3;
    map(ind) = NaN;
    cdata = ind2rgb(cdata,map);
    
    % Load cdata from *.png file
elseif length(filename)>3 && strncmp(filename(end-3:end),'.png',4)
    [cdata map alpha] = imread([ICONROOT,filename],'Background','none');
    % Converting 16-bit integer colors to MATLAB colorspec
    cdata = double(cdata) / 65535.0;
    % Set all transparent pixels to be transparent (nan)
    cdata(alpha==0) = NaN;
    
    % Load cdata from *.mat file
else
    temp = load([ICONROOT,filename],'cdata');
    cdata = temp.cdata;
end
end
