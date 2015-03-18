function varargout = YMazeGUI(varargin)
warning off
%YMazeGUI M-file for YMazeGUI.fig
%      YMazeGUI, by itself, creates a new YMazeGUI or raises the existing
%      singleton*.
%
%      H = YMazeGUI returns the handle to a new YMazeGUI or the handle to
%      the existing singleton*.
%
%      YMazeGUI('Property','Value',...) creates a new YMazeGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to YMazeGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      YMazeGUI('CALLBACK') and YMazeGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in YMazeGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help YMazeGUI

% Last Modified by GUIDE v2.5 17-Aug-2014 19:23:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @YMazeGUI_OpeningFcn, ...
    'gui_OutputFcn',  @YMazeGUI_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before YMazeGUI is made visible.
function YMazeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for YMazeGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes YMazeGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = YMazeGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
selection = get(handles.figure1,'SelectionType');
contents = cellstr(get(hObject,'String'));
idx = get(hObject,'Value');
curr_file = contents{idx};
curr_folder = handles.folder_name;
% Single click - normal selection, double-click = open. If normal
% selection, display left box, right box labels, ref index, and start
% index and ROIs. Double click opens the file in a media viewer
if(strcmp(selection,'open'))
    set(handles.pushbutton6,'Enable','on');
    if(ispc)
        try
            winopen([curr_folder '/' curr_file]);
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
        set(handles.pushbutton10,'Enable','off');
        set(handles.pushbutton11,'Enable','off');
        set(handles.pushbutton18,'Enable','off');
        set(handles.pushbutton13,'Enable','off');
        
        set(handles.pushbutton19,'Enable','off');
        set(handles.pushbutton20,'Enable','off');
        
        set(handles.edit7,'String',[]);
        set(handles.edit8,'String',[]);
        set(handles.edit13,'String',[]);
        
        set(handles.edit14,'String',[]);
        set(handles.edit15,'String',[]);
        set(handles.edit17,'String',[]);
        set(handles.edit18,'String',[]);
        
    else
        % Gray out fields that are not set yet
        if(~isfield(handles.Info(idx),'filename') || isempty(handles.Info(idx).filename))
            set(handles.pushbutton10,'Enable','off');
            set(handles.pushbutton11,'Enable','off');
            set(handles.pushbutton18,'Enable','off');
            set(handles.pushbutton13,'Enable','off');
            
            set(handles.pushbutton19,'Enable','off');
            set(handles.pushbutton20,'Enable','off');
        else
            set(handles.pushbutton10,'Enable','on');
            set(handles.pushbutton11,'Enable','on');
            set(handles.pushbutton13,'Enable','on');
            
            set(handles.pushbutton18,'Enable','on');
            set(handles.pushbutton19,'Enable','on');
            set(handles.pushbutton20,'Enable','on');
            
        end
        if(isfield(handles.Info(idx),'ref_idx'))
            set(handles.edit14,'String',num2str(handles.Info(idx).ref_idx));
        end
        
        if(isfield(handles.Info(idx),'start_idx'))
            set(handles.edit15,'String',num2str(handles.Info(idx).start_idx));
        end
        if(isfield(handles.Info(idx),'duration'))
            set(handles.edit17,'String',num2str(handles.Info(idx).duration));
        end
        if(isfield(handles.Info(idx),'length'))
            set(handles.edit18,'String',num2str(handles.Info(idx).length));
        end
    end
end

if(strcmp(selection,'normal'))
    set(handles.pushbutton6,'Enable','on');
    % Gray out fields that are not set yet
    if(idx>numel(handles.Info))
        set(handles.pushbutton10,'Enable','off');
        set(handles.pushbutton11,'Enable','off');
        set(handles.pushbutton13,'Enable','off');
        
        set(handles.pushbutton18,'Enable','off');
        set(handles.pushbutton19,'Enable','off');
        set(handles.pushbutton20,'Enable','off');
        set(handles.edit7,'Enable','on')
        set(handles.edit8,'Enable','on')
        set(handles.edit13,'Enable','on')
        
        
        set(handles.edit7,'String',[]);
        set(handles.edit8,'String',[]);
        set(handles.edit13,'String',[]);
        
        set(handles.edit14,'String',[]);
        set(handles.edit15,'String',[]);
        set(handles.edit17,'String',[]);
        set(handles.edit18,'String',[]);
    else
        if(~isfield(handles.Info(idx),'filename') || isempty(handles.Info(idx).filename))
            set(handles.pushbutton10,'Enable','off');
            set(handles.pushbutton11,'Enable','off');
            set(handles.pushbutton13,'Enable','off');
            
            set(handles.pushbutton18,'Enable','off');
            set(handles.pushbutton19,'Enable','off');
            set(handles.pushbutton20,'Enable','off');
            
            set(handles.edit7,'String',[]);
            set(handles.edit8,'String',[]);
            set(handles.edit13,'String',[]);
            set(handles.edit14,'String',[]);
            set(handles.edit15,'String',[]);
            set(handles.edit17,'String',[]);
            set(handles.edit18,'String',[]);
            set(handles.edit7,'Enable','on');
            set(handles.edit8,'Enable','on');
            set(handles.edit13,'Enable','on');
            
        else
            set(handles.pushbutton10,'Enable','on');
            set(handles.pushbutton11,'Enable','on');
            set(handles.pushbutton13,'Enable','on');
            
            set(handles.pushbutton18,'Enable','on');
            set(handles.pushbutton19,'Enable','on');
            set(handles.pushbutton20,'Enable','on');
            
            set(handles.edit7,'Enable','on');
            set(handles.edit8,'Enable','on');
            set(handles.edit13,'Enable','on');
            
        end
        % Update fields of labels
        
        if(isfield(handles.Info(idx),'Tag'))
            set(handles.edit13,'String',handles.Info(idx).Tag);
        end
        
        if(isfield(handles.Info(idx),'ref_time'))
            set(handles.edit7,'String',handles.Info(idx).ref_time_str);
        end
        if(isfield(handles.Info(idx),'start_time'))
            set(handles.edit8,'String',handles.Info(idx).start_time_str);
        end
        if(isfield(handles.Info(idx),'ref_idx'))
            set(handles.edit14,'String',num2str(handles.Info(idx).ref_idx));
        end
        
        if(isfield(handles.Info(idx),'start_idx'))
            set(handles.edit15,'String',num2str(handles.Info(idx).start_idx));
        end
        if(isfield(handles.Info(idx),'duration'))
            set(handles.edit17,'String',num2str(handles.Info(idx).duration));
        end
        if(isfield(handles.Info(idx),'length'))
            set(handles.edit18,'String',num2str(handles.Info(idx).length));
        end
    end
end
handles.curr_idx = idx;
handles.curr_file = curr_file;
guidata(hObject,handles);




% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.parent_dir = pwd;

guidata(hObject,handles);

% --- Executes on button press in pushbutton7 - browse folder containing
% SOR files
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir('','Select a folder containing SOR videos');
if(~isstr(folder_name))
    folder_name = handles.parent_dir;
end
handles.folder_name = folder_name;

guidata(hObject,handles);

load_listbox(folder_name,handles);
N = length(cellstr(get(handles.listbox3,'String')));
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
dir_struct = [dir_struct; dir('*.MPG')];
dir_struct = [dir_struct; dir('*.mov')];
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
set(handles.listbox3,'String',handles.file_names,...
    'Value',1)
set(handles.text11,'String',dir_path)
cd(handles.parent_dir);


% --- Executes on button press in pushbutton8 - show ROIs
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% choice = questdlg('Draw free-hand or automatically trace?','Metal object in right box','Auto','Free-hand','Cancel','Auto');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
try
    info = handles.Info(idx);
    I = info.ref_frame;
    h=figure;
    hax_fig = gca;
    imshow(info.ref_frame,'Parent',hax_fig);
    hfig = imgcf;
    hax = imgca;
    hold all
    
    B = bwboundaries(info.ROIs.Maze);
    for k = 1:length(B)
        boundary = B{k};
        plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
    end
    
    % Show the metal and glass objects in left box
    
    B = bwboundaries(info.ROIs.LeftArm);
    for k = 1:length(B)
        boundary = B{k};
        plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
    end
    
    
    B = bwboundaries(info.ROIs.RightArm);
    for k = 1:length(B)
        boundary = B{k};
        plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
    end
    
    
    B = bwboundaries(info.ROIs.Stem);
    for k = 1:length(B)
        boundary = B{k};
        plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
    end
    
    
    
    
    
end
% --- Executes on button press in pushbutton9 - save
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Info_tmp = handles.Info;
% Go through and only keep elements that have a filename field
cntr = 1;
for i=1:numel(Info_tmp)
    if(~isempty(Info_tmp(i).filename) && ~isempty(Info_tmp(i).ref_idx))
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
            disp(['YMaze Initializations saved to ' savefile]);
            
            
    end
else
    save(savefile,'Info');
    disp(['YMaze Initializations saved to ' savefile]);
end

button = questdlg('Do you want to batch process these files now or later?','Process now?','Now','Later','Later');
switch button
    case 'Now'
        h = msgbox('Submitting all files for batch processing.');
        pause(2);
        try
            delete(h);
        end
        YMazeBatch(handles.folder_name);
        
end


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
choice = get(hObject,'String');
handles.Info(idx).LeftLabel = choice;
if(~strcmp(choice,'na'))
    handles.Info(idx).LeftMouse = 1;
    set(handles.edit9,'Enable','on');
    set(handles.edit11,'Enable','on');
    set(handles.popupmenu2,'Enable','on');
else
    handles.Info(idx).LeftMouse = 0;
    set(handles.edit9,'Enable','off');
    set(handles.edit11,'Enable','off');
    set(handles.popupmenu2,'Enable','off');
end

guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
choice = get(hObject,'String');
handles.Info(idx).RightLabel = choice;
if(~strcmp(choice,'na'))
    handles.Info(idx).RightMouse = 1;
    set(handles.edit10,'Enable','on');
    set(handles.edit12,'Enable','on');
    set(handles.popupmenu6,'Enable','on');
else
    handles.Info(idx).RightMouse = 0;
    set(handles.edit10,'Enable','off');
    set(handles.edit12,'Enable','off');
    set(handles.popupmenu6,'Enable','off');
end
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ref time
function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
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
handles.Info(idx).ref_time_str = s;
handles.Info(idx).ref_time = minute*60+sec;

set(handles.text25,'String','Threshold = ');
handles.Info(handles.curr_idx).thresh = [];

guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double

try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
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
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6 - Apply
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Need to read video file, pull up the right ref frame and ask user to draw
% ROIs
% Error checking - make sure ref time, start time and mouse label fields
% are not empty
set(hObject,'Enable','off');
set(hObject,'Selected','on');
set(handles.pushbutton10,'Enable','off');
set(handles.pushbutton11,'Enable','off');
set(handles.pushbutton13,'Enable','off');

set(handles.pushbutton18,'Enable','off');
pause(1e-3)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

if(isempty(info.ref_time))
    errordlg('You must enter a time for empty box','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end

if(isempty(info.start_time))
    errordlg('You must enter a time when mouse is placed in the box','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end
h = msgbox('Please wait while determining frame #.');
if(isfield(info,'ref_idx') && ~isempty(info.ref_idx))
    V = mmread(info.filename,info.ref_idx);
    info.ref_frame = V(end).frames.cdata;
end
if(isfield(info,'start_idx') && ~isempty(info.start_idx))
    V = mmread(info.filename,info.start_idx);
    info.start_frame = V(end).frames.cdata;
end

% if(~isfield(info,'start_frame') || isempty(info.start_frame))
% Video recorded at <30fps - use the start time to gauge how many
% frames to read

vidname = [handles.folder_name '/' handles.curr_file];
ref_frame = TimeToFrame(vidname,1,(info.ref_time+5)*30,info.ref_time);
set(handles.edit14,'String',num2str(ref_frame));
start_frame = TimeToFrame(vidname,ref_frame,(info.start_time+5)*30,info.start_time);
set(handles.edit15,'String',num2str(start_frame));
% else
%     set(handles.edit14,'String',num2str(info.ref_idx));
%     set(handles.edit15,'String',num2str(info.start_idx));

% end
% if(ref_frame== -1)
%     errordlg('Reference frame not found within the first 5000 frames. Make a note of this file and manually adjust','Reference frame invalid','modal');
%     uicontrol(hObject)
%     return
% end
% if(start_frame==-1)
%     errordlg('Start frame not found within the first 5000 frames. Make a note of this file and manually adjust','Reference frame invalid','modal');
%     uicontrol(hObject)
%     return
% end

% Enable controls on ROI selection
delete(h)
set(handles.pushbutton10,'Enable','on');
set(handles.pushbutton11,'Enable','on');
set(handles.pushbutton13,'Enable','on');

set(handles.pushbutton18,'Enable','on');
set(handles.pushbutton19,'Enable','on');
set(handles.pushbutton20,'Enable','on');
set(handles.edit14,'Enable','on');
set(handles.edit15,'Enable','on');

% ROIs=InitializeSOR(vidname,ref_frame,info.Objects,LeftMouse,RightMouse);
handles.Info(idx).ref_idx = ref_frame;
vidname = [handles.folder_name '/' handles.curr_file];
V = mmread(vidname,ref_frame);
handles.Info(idx).ref_frame = V(end).frames.cdata;
handles.Info(idx).start_idx = start_frame;
V = mmread(vidname, handles.Info(idx).start_idx);
handles.Info(idx).start_frame = V(end).frames.cdata;
% handles.Info(idx).ROIs = ROIs;
handles.Info(idx).filename = vidname;
set(handles.pushbutton6,'Enable','on');
set(handles.pushbutton6,'Selected','off');
guidata(hObject,handles);


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


% --- Executes on button press in pushbutton10 - left half
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

h=figure;
hax_fig = gca;
imshow(info.ref_frame,'Parent',hax_fig);
hfig = imgcf;
hax = imgca;
hfree = impoly(hax);
wait(hfree);
BW = hfree.createMask;
handles.Info(idx).ROIs.LeftArm=BW;
% Delete figure
delete(hfig);

guidata(hObject,handles);
% --- Executes on button press in pushbutton11 - glass left
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
I = info.ref_frame;
h=figure;
hax_fig = gca;
imshow(info.ref_frame,'Parent',hax_fig);
hfig = imgcf;
hax = imgca;
hobject1 = impoly(hax);
wait(hobject1);
handles.Info(idx).ROIs.Stem = hobject1.createMask;

delete(hfig);

guidata(hObject,handles);
% --- Executes on button press in pushbutton12.

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
h=figure;
hax_fig = gca;
imshow(info.ref_frame,'Parent',hax_fig);
hfig = imgcf;
hax = imgca;
hfree = impoly(hax);
wait(hfree);
BW = hfree.createMask;
handles.Info(idx).ROIs.RightArm = BW;
% Delete figure
delete(hfig);

guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function pushbutton10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off');


% --- Executes during object creation, after setting all properties.
function pushbutton11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off');


% --- Executes during object creation, after setting all properties.
function pushbutton12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off');


% --- Executes during object creation, after setting all properties.
function pushbutton13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off');





% --- Executes during object creation, after setting all properties.
function pushbutton15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off');


% --- Executes on button press in pushbutton17 - load existing info.mat
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
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
idx = strfind(Info(1).filename,'/');

if(isempty(idx))
    idx = strfind(Info(1).filename,'\');
end

handles.folder_name = dirpath;
for i=1:numel(Info)
    [~,x,ext] = fileparts(Info(i).filename);
    filename{i} = [x ext];
    %     filename{i} = Info(i).filename(idx(end)+1:end);
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
% for i=1:numel(fnames)
%     if(~strcmp(fnames(i).name,filename))
%         filename{end+1} = fnames(i).name;
%     end
% end

set(handles.listbox3,'String',filename,...
    'Value',1)
set(handles.text11,'String',handles.folder_name)

handles.Info = Info;
guidata(hObject,handles);

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
contents = cellstr(get(hObject,'String'));

selection = contents{get(hObject,'Value')};
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).LeftSessionID = selection;
handles.Info(idx).LeftSessionValue = get(hObject,'Value');
if(get(hObject,'Value')>2)
    handles.Info(idx).LeftObjects = 1;
else
    handles.Info(idx).LeftObjects = 0;
end
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
% end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).LeftTag = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).RightTag = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
contents = cellstr(get(hObject,'String'));

selection = contents{get(hObject,'Value')};
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).InjuryGroup = selection;
handles.Info(idx).InjuryValue = get(hObject,'Value');

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
% end


% --- Executes during object creation, after setting all properties.
function text15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6
contents = cellstr(get(hObject,'String'));

selection = contents{get(hObject,'Value')};
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).RightSessionID = selection;
handles.Info(idx).RightSessionValue = get(hObject,'Value');
if(get(hObject,'Value')>2)
    handles.Info(idx).RightObjects = 1;
else
    handles.Info(idx).RightObjects = 0;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
% end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double

try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).RightInjGrp = get(hObject,'String');
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
% end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double

try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).LeftInjGrp = get(hObject,'String');
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
% end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).Tag = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

set(hObject,'BackgroundColor','white');



% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

h=figure;
hax_fig = gca;
imshow(info.ref_frame,'Parent',hax_fig);
hfig = imgcf;
hax = imgca;
%         hfree = imellipse(hax);
%         handles.Info(idx).ROIs.BWin=hfree.createMask;
%         hfree = imellipse(hax);
%         handles.Info(idx).ROIs.BWout=hfree.createMask;
hfree = impoly(hax);
wait(hfree);
%         handles.Info(idx).ROIs.Maze = handles.Info(idx).ROIs.BWout - handles.Info(idx).ROIs.BWin;
handles.Info(idx).ROIs.Maze = hfree.createMask;
% Delete figure
delete(hfig);

guidata(hObject,handles);


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

h=figure;
hax_fig = gca;
imshow(info.ref_frame,'Parent',hax_fig);

% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

h=figure;
hax_fig = gca;
imshow(info.start_frame,'Parent',hax_fig);


function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).ref_idx = str2double(get(hObject,'String'));
V = mmread(handles.Info(idx).filename, handles.Info(idx).ref_idx);
handles.Info(idx).ref_frame = V(end).frames.cdata;

t = V(end).times;
min = floor(t/60);
sec = mod(t,60);
ref_time_str = [num2str(min) ':' num2str(sec)];
set(handles.edit7,'String',ref_time_str);
handles.Info(idx).ref_time_str = ref_time_str;
handles.Info(idx).ref_time = t;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).start_idx = str2double(get(hObject,'String'));
V = mmread(handles.Info(idx).filename, handles.Info(idx).start_idx);
handles.Info(idx).start_frame = V(end).frames.cdata;
t = V(end).times;
min = floor(t/60);
sec = mod(t,60);
start_time_str = [num2str(min) ':' num2str(sec)];
set(handles.edit8,'String',[num2str(min) ':' num2str(sec)]);
handles.Info(idx).start_time_str = start_time_str;
handles.Info(idx).start_time = t;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double
handles.Info(handles.curr_idx).duration = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double
handles.Info(handles.curr_idx).length = str2double(get(hObject,'String'));
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isfield(handles,'curr_idx') || isempty(handles.curr_idx))
    errordlg('Please select a video from the listbox first');
    uiwait(hObject);
end
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
try
    start_idx = handles.Info(idx).start_idx;
catch
    errordlg('Please enter start time and click Apply first (step 1)');
    uiwait(hObject);
end
try
    maze = handles.Info(idx).ROIs.Maze;
catch
    errordlg('Please select Maze ROIs first. (Step 2)');
end
rand_idx = randsample(500,1) + start_idx;
% Read 20 frames and pick the middle because mmread occasionally does not fetch the frame if a single frame is read
V = mmread(handles.Info(idx).filename,rand_idx:rand_idx+20);
V = V(end);
I = rgb2gray(V.frames(10).cdata);
I = double(I.*uint8(maze));
if(isfield(handles.Info(idx),'thresh') && ~isempty(handles.Info(idx).thresh))
    thresh = handles.Info(idx).thresh;
else
    if(handles.Info(idx).ref_time==0)
        thresh = 7;
    else
        thresh = 80;
    end
    handles.Info(idx).thresh = thresh;
    set(handles.text25,'String',['Threshold = ' num2str(thresh)]);
end
if(handles.Info(idx).ref_time==0)
    BW = I./mean(I(:))<thresh & I./mean(I(:)) >0;
    
    L = SegmentMouse(BW);
    figure;
    subplot(1,2,1); imshow(I./mean(I(:)),[]);
    hold on
    B = bwboundaries(L);
    for k=1:length(B)
        plot(B{k}(:,2),B{k}(:,1),'r','LineWidth',2);
    end
    subplot(1,2,2); imshow(L);
else
    D = rgb2gray(imabsdiff(handles.Info(idx).ref_frame,V.frames(10).cdata));
    D = D.*uint8(maze);
    L = SegmentMouse(D>thresh);
    B = bwboundaries(L);
    % Display
    h = figure;
    hax = gca;
    subplot(2,2,1), imagesc(handles.Info(idx).ref_frame); colormap('gray'); title('Background'); freezeColors; set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
    subplot(2,2,2), imagesc(V.frames(10).cdata); colormap('gray'); title('Image frame to segment'); freezeColors; set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
    hold on
    for i=1:length(B)
        plot(B{i}(:,2),B{i}(:,1),'r','LineWidth',1);
    end
    hold off
    subplot(2,2,3), imagesc(D); colormap('jet'); title('Background subtracted image'); freezeColors; set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
    subplot(2,2,4), imagesc(L); colormap('gray'); title('Segmentation'); freezeColors; set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
    
end
guidata(hObject,handles);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = get(hObject,'Value');
if(val>10)
    val = floor(val);
end
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
YMaze(handles.Info(handles.curr_idx),'DISPLAY',1);
