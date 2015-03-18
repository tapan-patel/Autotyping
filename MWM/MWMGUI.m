function varargout = MWMGUI(varargin)
% MWMGUI MATLAB code for MWMGUI.fig
%      MWMGUI, by itself, creates a new MWMGUI or raises the existing
%      singleton*.
%
%      H = MWMGUI returns the handle to a new MWMGUI or the handle to
%      the existing singleton*.
%
%      MWMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MWMGUI.M with the given input arguments.
%
%      MWMGUI('Property','Value',...) creates a new MWMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MWMGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MWMGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MWMGUI

% Last Modified by GUIDE v2.5 22-Feb-2015 19:43:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MWMGUI_OpeningFcn, ...
    'gui_OutputFcn',  @MWMGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MWMGUI is made visible.
function MWMGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MWMGUI (see VARARGIN)

% Choose default command line output for MWMGUI
handles.output = hObject;
if(isempty(which('mmread')))
    addpath('../mmread');
end
if(isempty(which('inpaint_nans')))
    addpath('../Inpaint_nans');
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MWMGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MWMGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

selection = get(handles.figure1,'SelectionType');
contents = cellstr(get(hObject,'String'));
idx = get(hObject,'Value');
curr_file = contents{idx};
curr_folder = handles.folder_name;
% Single click - normal selection, double-click = open. If normal
% selection, display left box, right box labels, ref index, and start
% index and ROIs. Double click opens the file in a media viewer
if(strcmp(selection,'open'))
    handles.Info(idx).filename = fullfile(curr_folder,curr_file);
    set(handles.pushbutton3,'Enable','on');
    if(ispc)
        try
            winopen(handles.Info(idx).filename);
        catch
            h=msgbox('Sorry! Can not find a native video player to play this movie from within MATLAB. Please use an alternative player (perhaps VLC) to determine start time.');
            uiwait(h);
        end
    elseif(isunix)
        try
            parent_folder = pwd;
            cd(curr_folder);
            eval(['!totem ' curr_file]);
            cd(parent_folder);
        catch
            h=msgbox('Sorry! Can not find a native video player to play this movie from within MATLAB. Please use an alternative player (perhaps VLC) to determine start time.');
            uiwait(h);
            cd(parent_folder);
        end
    elseif(ismac)
        try
        parent_folder = pwd;
            cd(curr_folder);
            eval(['!/Applications/VLC.app/Contents/MacOS/VLC ' curr_file]);
            cd(parent_folder);
        catch
             h=msgbox('Sorry! Could not locate VLC player. Make sure VLC is installed /Applications/VLC.app');
            uiwait(h);
            cd(parent_folder);
        end
    end
    
    if(idx>numel(handles.Info))
        
        set(handles.edit11,'String',[]);
        set(handles.edit2,'String',[]);
        set(handles.edit3,'String',[]);
        set(handles.edit4,'String',[]);
        set(handles.edit5,'String',[]);
        set(handles.edit6,'String',[]);
        set(handles.edit12,'String',[]);
        set(handles.edit13,'String',[]);
        
        set(handles.text6,'String','Frame #');
        
    else
        % Gray out fields that are not set yet
        
        if(isfield(handles.Info(idx),'start_idx'))
            set(handles.text6,'String',['Frame # ' num2str(handles.Info(idx).start_idx)]);
        end
    end
end

if(strcmp(selection,'normal'))
    handles.Info(idx).filename = fullfile(curr_folder,curr_file);
    set(handles.pushbutton3,'Enable','on');
    % Gray out fields that are not set yet
    if(idx>numel(handles.Info))
        
        set(handles.edit11,'String',[]);
        set(handles.edit2,'String',[]);
        set(handles.edit3,'String',[]);
        set(handles.edit4,'String',[]);
        set(handles.edit5,'String',[]);
        set(handles.edit6,'String',[]);
          set(handles.edit12,'String',[]);
        set(handles.edit13,'String',[]);
       
        
    end
    % Update fields of labels
    if(isfield(handles.Info(idx),'Tag'))
        Mouse = ~strcmp(handles.Info(idx).Tag,'na');
        handles.Info(idx).Mouse = Mouse;
        
        set(handles.edit11,'String',handles.Info(idx).Tag);
    end
    
    
    if(isfield(handles.Info(idx),'start_time'))
        set(handles.edit2,'String',handles.Info(idx).start_time_str);
        set(handles.edit12,'String',num2str(handles.Info(idx).start_idx));
    end
    if(isfield(handles.Info(idx),'end_idx'))
        set(handles.edit3,'String',handles.Info(idx).end_time_str);
        set(handles.edit13,'String',num2str(handles.Info(idx).end_idx));
    end
    if(isfield(handles.Info(idx),'dimensions_L'))
        set(handles.edit4,'String',num2str(handles.Info(idx).dimensions_L));
    end
    
    if(isfield(handles.Info(idx),'dimensions_W'))
        set(handles.edit5,'String',num2str(handles.Info(idx).dimensions_W));
    end
    if(isfield(handles.Info(idx),'perimeter'))
        set(handles.edit6,'String',num2str(handles.Info(idx).perimeter));
    end
    
  
end

handles.curr_idx = idx;
handles.curr_file = curr_file;
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.parent_dir = pwd;

guidata(hObject,handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir('','Select a folder containing Open Field videos');
if(~isstr(folder_name))
    folder_name = handles.parent_dir;
end
handles.folder_name = folder_name;

guidata(hObject,handles);

load_listbox(folder_name,handles);
N = length(cellstr(get(handles.listbox1,'String')));
Info = repmat(struct(),N,1);
handles.Info = Info;
guidata(hObject,handles);

function load_listbox(dir_path,handles)
cd(dir_path);
dir_struct = dir('*.wmv');
dir_struct = [dir_struct; dir('*.avi')];
dir_struct = [dir_struct; dir('*.mpeg')];
dir_struct = [dir_struct; dir('*.mpg')];
dir_struct = [dir_struct; dir('*.mp4')];
% dir_struct = [dir_struct; dir('*.MPG')];
dir_struct = [dir_struct; dir('*.mov')];
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
set(handles.listbox1,'String',handles.file_names,...
    'Value',1)
set(handles.text1,'String',dir_path)
cd(handles.parent_dir);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[info_name, dirpath] = uigetfile('*.mat','Select a info.mat file');

try
    load([dirpath info_name]);
catch
    
    errordlg('Make an appropriate selection of info.mat file','Bad Input','modal')
    uicontrol(hObject)
    return;
end


% Now populate listbox3


handles.folder_name = dirpath;
for i=1:numel(Info)
     [~,x,ext] = fileparts(Info(i).filename);
      filename{i} = [x ext];
end
% Populate with other files in the directory that are not part of
% info.mat
parent_dir = pwd;
cd(handles.folder_name);
fnames = dir('*.wmv');
fnames = [fnames;dir('*.avi')];
fnames = [fnames;dir('*.mpg')];
fnames = [fnames;dir('*.mpeg')];
fnames = [fnames;dir('*.mp4')];
fnames = [fnames;dir('*.mov')];
fnames = [fnames;dir('*.MPG')];
% Go back to parent_dire
cd(parent_dir);
for i=1:numel(fnames)
    if(~strcmp(fnames(i).name,filename))
        filename{end+1} = fnames(i).name;
    end
end

set(handles.listbox1,'String',filename,...
    'Value',1)
set(handles.text1,'String',handles.folder_name)

% % Update Info elements to have a ref image
% disp('Please wait while info.mat is loaded into workspace');
% h = msgbox('Please wait while loading videos. This message will self destruct');
% t1 = clock;
% for i=1:numel(Info)
%     disp(['Loading ' num2str(i) ' of ' num2str(numel(Info))]);
%     if(etime(clock,t1)>120)
%         t1 = clock;
%         continue
%     end
%     if(~isfield(Info(i),'ref_frame') || isempty(Info(i).ref_frame))
%         V = mmread(Info(i).filename,Info(i).ref_idx);
%         Info(i).ref_frame = V(end).frames.cdata;
%     end
%     
% end
% delete(h);
handles.Info = Info;
guidata(hObject,handles);
% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Info_tmp = handles.Info;
% Go through and only keep elements that have a filename field
cntr = 1;
for i=1:numel(Info_tmp)
    if(~isempty(Info_tmp(i).filename))
        % Fix filename if it was done on non-linux computer
        filename = Info_tmp(i).filename;
        Info(cntr) = Info_tmp(i);
        cntr = cntr+1;
    end
end
savefile = [handles.folder_name '/info.mat'];

% If already exists, ask if you want to overwrite
if(exist(savefile))
    choice = questdlg([savefile ' already exists. Overwrite?']);
    switch choice
        case 'Yes'
            save(savefile,'Info');
            disp(['MWM Initializations saved to ' savefile]);
            
      
    end
else
    save(savefile,'Info');
    disp(['MWM Initializations saved to ' savefile]);
end

button = questdlg('Do you want to batch process these files now or later?','Process now?','Now','Later','Later');
switch button
    case 'Now'
%        h = msgbox('Submitting all files for batch processing. Please look at the MATLAB command window for progress of your analysis. This GUI will now exit in 10 seconds.');
%        pause(10);
%        delete(h);
%        delete(handles.figure1);
%        pause(1e-3);
        MWMBatch(handles.folder_name);
        
end
% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Enable','off');
set(hObject,'Selected','on');
idx = handles.curr_idx;
info = handles.Info(idx);
start_idx = 120*30;

h = msgbox('Please wait while estimating background image. This message will self destruct');

frames = mmcount(info.filename);

if(isnan(frames))
    vid = VideoReader(info.filename);
    
    if(isempty(vid.NumberOfFrames))
        read(vid,inf);
    end
    
    frames = vid.NumberOfFrames;
end
indices = randsample(frames-start_idx,min([100 frames-start_idx]))+(start_idx);
indices(indices>frames) = [];
indices = sort(indices);
V = mmread(info.filename,indices); V = V(end);
A = zeros(V.height,V.width,length(V.frames));
for i=1:length(V.frames)
A(:,:,i) = rgb2gray(V.frames(i).cdata);
end
Bkg = uint8(mode(double(A),3));

% Fix any 0's - this arises if the mouse sits in one location for most of
% the video and is incorporated as part of the background
Bkg = double(Bkg);
Bkg(Bkg==0) = nan;
Bkg = uint8(inpaint_nans(Bkg,2));

handles.Info(idx).ref_frame = Bkg;
handles.Info(idx).frames = frames;
set(hObject,'Enable','on');
set(hObject,'Selected','off');
delete(h);
h = figure; imshow(Bkg); pause(1); close(h);
guidata(hObject,handles);
% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = msgbox('Please wait while determining background. This may take several minutes');
set(hObject,'Enable','off');
set(hObject,'Selected','on');
files = get(handles.listbox1,'String');
folder = get(handles.text1,'String');
set(handles.pushbutton17,'Enable','off');
set(handles.pushbutton3,'Enable','off');
set(handles.pushbutton21,'Enable','off');
set(handles.pushbutton20,'Enable','off');
set(handles.pushbutton11,'Enable','off');
set(handles.pushbutton10,'Enable','off');
set(handles.pushbutton22,'Enable','off');
pause(1e-4);
drawnow;
for i=1:numel(files)
    filename = fullfile(folder,files{i});
    disp(['Determining background for ' filename]);
    start_idx = 120*30;
    frames = mmcount(filename);
    if(isnan(frames))
        vid = VideoReader(filename);
        if(isempty(vid.NumberOfFrames))
            read(vid,inf);
        end
        frames = vid.NumberOfFrames;
    end
    Bkg = EstimateBackground(filename,frames,start_idx);
    handles.Info(i).filename = filename;
    handles.Info(i).ref_frame = Bkg;
    handles.Info(i).frames = frames;
    disp(['Background estimation done: ' filename]);
end
set(hObject,'Enable','on');
set(hObject,'Selected','off');

set(handles.pushbutton3,'Enable','on');
set(handles.pushbutton21,'Enable','on');
set(handles.pushbutton20,'Enable','on');
set(handles.pushbutton11,'Enable','on');
set(handles.pushbutton10,'Enable','on');
set(handles.pushbutton22,'Enable','on');
delete(h)
guidata(hObject,handles);
% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = handles.curr_idx;
try
    info = handles.Info(idx);
    I = info.ref_frame;
    Mouse = ~strcmp(info.Tag,'na');
    
    h=figure;
    hax_fig = gca;
    imshow(info.ref_frame,'Parent',hax_fig);
    hfig = imgcf;
    hax = imgca;
    hold all
    if(Mouse)
        % Show trace of the box
        if(isfield(info.ROIs,'surface') && ~isempty(info.ROIs.surface))
            B = bwboundaries(info.ROIs.surface);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            end
            
        end
        
        if(isfield(info.ROIs,'platform') && ~isempty(info.ROIs.platform))
            B = bwboundaries(info.ROIs.platform);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            end
            
        end
        % Show the metal and glass objects in left box
    end
end
% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Draw free-hand or rectangle?','Maze ROI','Ellipse','Free-hand','Cancel','Ellipse');
idx = handles.curr_idx;
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imfreehand(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface = BW;
        delete(hfig);
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imellipse(hax);
        wait(hrect);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface = BW;
        delete(hfig);
end
guidata(hObject,handles);


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

idx = handles.curr_idx;
s=get(hObject,'String');
[minute,sec] = strtok(s,':');
if(isempty(sec))
    errordlg('You must enter time as min:sec (e.g. 0:34 or 2:56)','Bad Input','modal')
    uicontrol(hObject)
    return
end
minute = str2double(minute);
sec = str2double(sec(2:end));
% Convert from min:sec to seconds
handles.Info(idx).start_time_str = s;
handles.Info(idx).start_time = minute*60+sec;
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'Selected','on');

pause(1e-3)
idx = handles.curr_idx;
info = handles.Info(idx);
try
    Mouse = ~strcmp(info.Tag,'na');
    
catch
    errordlg('You must enter a label for the mouse. (na = no mouse)','Bad Input','modal')
    set(handles.pushbutton3,'Enable','on');
    uicontrol(hObject)
    return
end
if(Mouse)
    if(~isfield(info,'Tag') || isempty(info.Tag))
        errordlg('You must enter a tag for the mouse','Bad Input','modal')
        set(handles.pushbutton3,'Enable','on');
        uicontrol(hObject)
        return
    end
end

if(isempty(info.start_time))
    errordlg('You must enter a time when mouse is placed in the maze','Bad Input','modal')
    set(handles.pushbutton3,'Enable','on');
    uicontrol(hObject)
    return
end

if(isempty(info.end_time))
    errordlg('You must enter an end time','Bad Input','modal')
    set(handles.pushbutton3,'Enable','on');
    uicontrol(hObject)
    return
end
h = msgbox('Please wait while determining frame #. This message will self destruct');

if(~isfield(info,'start_frame') || isempty(info.start_frame))
    % Video recorded at <30fps - use the start time to gauge how many
    % frames to read
    
    vidname = [handles.folder_name '/' handles.curr_file];
    
    start_frame = TimeToFrame(vidname,1,(info.start_time+10)*30,info.start_time);
  

end

if(start_frame==-1)
    handles.Info(idx).Tag = 'na';
    handles.Info(idx).Mouse = 0;
    errordlg('Start frame not found. This file will be skipped','Start frame invalid','modal');
    uicontrol(hObject)
    return
end


if(~isfield(info,'end_frame') || isempty(info.end_frame))
    % Video recorded at <30fps - use the start time to gauge how many
    % frames to read
    
    vidname = [handles.folder_name '/' handles.curr_file];
    
    end_frame = TimeToFrame(vidname,1,(info.end_time+10)*30,info.end_time);
%     set(handles.text6,'String',['Frame # ' num2str(start_frame)]);
% else    
%     set(handles.text6,'String',['Frame # ' num2str(info.start_frame)]);
    
end

if(end_frame==-1)
    handles.Info(idx).Tag = 'na';
    handles.Info(idx).Mouse = 0;
    errordlg('End frame not found. This file will be skipped','End frame invalid','modal');
    uicontrol(hObject)
    return
end

vidname = [handles.folder_name '/' handles.curr_file];

handles.Info(idx).start_idx = start_frame;
handles.Info(idx).end_idx = end_frame;
set(handles.edit12,'String',num2str(start_frame));
set(handles.edit13,'String',num2str(end_frame));
handles.Info(idx).filename = vidname;
if(isfield(handles.Info(idx),'frames') && ~isempty(handles.Info(idx).frames))
frames = handles.Info(idx).frames;
else
    frames = mmcount(vidname);
end
if(isnan(frames))
    vid = VideoReader(vidname);
    
    if(isempty(vid.NumberOfFrames))
        read(vid,inf);
    end
    
    frames = vid.NumberOfFrames;
end
if(~isfield(handles.Info(idx),'ref_frame') || isempty(handles.Info(idx).ref_frame))
    handles.Info(idx).ref_frame = EstimateBackground(vidname,frames,start_frame);
end

handles.Info(idx).frames = frames;
delete(h);
h = figure; imshow(handles.Info(idx).ref_frame); pause(1); close(h);
set(handles.pushbutton3,'Enable','on');
set(handles.pushbutton3,'Selected','off');
guidata(hObject,handles);


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
idx = handles.curr_idx;
s=get(hObject,'String');
[minute,sec] = strtok(s,':');
if(isempty(sec))
    errordlg('You must enter time as min:sec (e.g. 0:34 or 2:56)','Bad Input','modal')
    uicontrol(hObject)
    return
end
minute = str2double(minute);
sec = str2double(sec(2:end));
% Convert from min:sec to seconds
handles.Info(idx).end_time_str = s;
handles.Info(idx).end_time = minute*60+sec;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

idx = handles.curr_idx;
s=get(hObject,'String');
% Convert from min:sec to seconds
handles.Info(idx).dimensions_L = str2double(s);
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

idx = handles.curr_idx;
s=get(hObject,'String');
% Convert from min:sec to seconds
handles.Info(idx).dimensions_W = str2double(s);
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

idx = handles.curr_idx;
s=get(hObject,'String');
% Convert from min:sec to seconds
handles.Info(idx).perimeter = str2double(s);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double

idx = handles.curr_idx;
handles.Info(idx).Tag = get(hObject,'String');
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
choice = questdlg('Really quit? Did you click Save first?');
if(strcmp(choice,'No') || strcmp(choice,'Cancel'))
    uicontrol(hObject);
    return
else
    
    delete(hObject);
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = handles.curr_idx;
% Show the background 
h = figure;
hax = gca;
imshow(handles.Info(idx).ref_frame,'Parent',hax);
title('Define an area to sample pixel intesity');
h1 = impoly;
BW = h1.createMask;
m = median(handles.Info(idx).ref_frame(BW));
delete(h1);
title('Freehand an area to replace pixel intensity with that of neighbor, denied above');
h1 = imfreehand;
BW = h1.createMask;
handles.Info(idx).ref_frame(BW) = m;
imshow(handles.Info(idx).ref_frame,'Parent',hax);
guidata(hObject,handles);


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = handles.curr_idx;
% Show the background 
h = figure;
hax = gca;
imshow(handles.Info(idx).ref_frame,'Parent',hax);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = floor(get(hObject,'Value'));
set(handles.text25,'String',['Threshold = ' num2str(val)]);
try
    handles.Info(handles.curr_idx).thresh = val;
catch
    errordlg('Please select a video file first.');
    uiwait(hObject);
end
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(~isfield(handles,'curr_idx') || isempty(handles.curr_idx))
    errordlg('Please select a video from the listbox first');
    uiwait(hObject);
end
idx = handles.curr_idx;
try
    start_idx = handles.Info(idx).start_idx;
catch
    errordlg('Please enter start time and click Apply first (step 1)');
    uiwait(hObject);
end
try
    frames = handles.Info(idx).frames;
catch
    errordlg('Please click Apply first (step 1)');
    uiwait(hObject);
end
try
    ref_frame = handles.Info(idx).ref_frame;
catch
    errordlg('Please get background image first. (Step 0 or 1)');
end
try
    surface = handles.Info(idx).ROIs.surface;
catch
    errordlg('Please select ROIs first. (Step 3)');
end

rand_idx = randsample(frames-start_idx,1) + start_idx;
% Read 20 frames and pick the middle because mmread occasionally does not fetch the frame if a single frame is read
V = mmread(handles.Info(idx).filename,rand_idx:rand_idx+20); 
V = V(end);
I = rgb2gray(V.frames(10).cdata);
D = imabsdiff(I,ref_frame);
D = imfill(D,'holes');
D = D.*uint8(surface);
if(isfield(handles.Info(idx),'thresh') && ~isempty(handles.Info(idx).thresh))
    thresh = handles.Info(idx).thresh;
else
    thresh = floor(graythresh(D)*255);
    handles.Info(idx).thresh = thresh;
    set(handles.text25,'String',['Threshold = ' num2str(thresh)]);
end
    
L = SegmentMouse(D>thresh,D,1);
B = bwboundaries(L);
% Display
h = figure;
hax = gca;
subplot(2,2,1), imagesc(ref_frame); colormap('gray'); title('Background'); freezeColors; set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
subplot(2,2,2), imagesc(I); colormap('gray'); title('Image frame to segment'); freezeColors; set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
hold on
for i=1:length(B)
    plot(B{i}(:,2),B{i}(:,1),'r','LineWidth',1);
end
hold off
subplot(2,2,3), imagesc(D); colormap('jet'); title('Background subtracted image'); freezeColors; set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
subplot(2,2,4), imagesc(L); colormap('gray'); title('Segmentation'); freezeColors; set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MWM(handles.Info(handles.curr_idx),'DISPLAY',1);


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or rectangle?','Platform ROI','Ellipse','Free-hand','Cancel','Ellipse');
idx = handles.curr_idx;
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imfreehand(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.platform = BW;
        delete(hfig);
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imellipse(hax);
        wait(hrect);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.platform = BW;
        delete(hfig);
end
guidata(hObject,handles);



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double
try
    idx = str2double(get(hObject,'String'));
    V = mmread(handles.Info(handles.curr_idx).filename,idx);
    handles.Info(handles.curr_idx).start_idx = idx;
    set(handles.edit2,'String',num2str(V(end).times));
catch
    errordlg('Make sure a file name is selected before entering frame #','Bad input','modal');
    return;
end
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double

try
    idx = str2double(get(hObject,'String'));
    V = mmread(handles.Info(handles.curr_idx).filename,idx);
    handles.Info(handles.curr_idx).end_idx = idx;
    set(handles.edit3,'String',num2str(V(end).times));
catch
    errordlg('Make sure a file name is selected before entering frame #','Bad input','modal');
    return;
end
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    V = mmread(handles.Info(handles.curr_idx).filename,handles.Info(handles.curr_idx).start_idx);
    figure; imshow(V.frames.cdata);
catch
    errordlg('Could not read frame. Make sure a video file is selected and frame number exists','Bad input','modal');
    return;
end
% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    V = mmread(handles.Info(handles.curr_idx).filename,handles.Info(handles.curr_idx).end_idx);
    figure; imshow(V.frames.cdata);
catch
    errordlg('Could not read frame. Make sure a video file is selected and frame number exists','Bad input','modal');
    return;
end
