function varargout = FCGUI(varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania

% FCGUI MATLAB code for FCGUI.fig
%      FCGUI, by itself, creates a new FCGUI or raises the existing
%      singleton*.
%
%      H = FCGUI returns the handle to a new FCGUI or the handle to
%      the existing singleton*.
%
%      FCGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FCGUI.M with the given input arguments.
%
%      FCGUI('Property','Value',...) creates a new FCGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FCGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FCGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FCGUI

% Last Modified by GUIDE v2.5 19-Aug-2014 14:25:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FCGUI_OpeningFcn, ...
    'gui_OutputFcn',  @FCGUI_OutputFcn, ...
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


% --- Executes just before FCGUI is made visible.
function FCGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FCGUI (see VARARGIN)

% Choose default command line output for FCGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FCGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FCGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folder_name = uigetdir('','Select a folder containing fear conditioning videos');
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
dir_struct = [dir_struct; dir('*.MPG')];
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
        set(handles.edit2,'String',[]);
        set(handles.edit1,'String',[]);
        set(handles.edit6,'String',[]);
    else
        % Gray out fields that are not set yet
        
        if(isfield(handles.Info(idx),'start_idx'))
            set(handles.text3,'String',['Frame # ' num2str(handles.Info(idx).start_idx)]);
        end
        
    end
end
if(strcmp(selection,'normal'))
    handles.Info(idx).filename = fullfile(curr_folder,curr_file);
    if(idx>numel(handles.Info))
        set(handles.edit2,'String',[]);
        set(handles.edit1,'String',[]);
        set(handles.edit6,'String',[]);
    end
    if(isfield(handles.Info(idx),'Tag'))
        Mouse = ~strcmp(handles.Info(idx).Tag,'na');
        handles.Info(idx).Mouse = Mouse;
        
        set(handles.edit6,'String',handles.Info(idx).Tag);
    end
    if(isfield(handles.Info(idx),'start_time'))
        set(handles.edit1,'String',handles.Info(idx).start_time_str);
    end
    if(isfield(handles.Info(idx),'duration'))
        set(handles.edit2,'String',handles.Info(idx).duration_str);
    end
    if(isfield(handles.Info(idx),'start_idx'))
        set(handles.text3,'String',['Frame # ' num2str(handles.Info(idx).start_idx)]);
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

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Do you have a video of empty FC chamber?','Empty box video?','Yes','No','Yes');
switch choice
    case 'Yes'
        [file,folder] = uigetfile('','Please select video of an empty FC chamber');
        x = inputdlg('Enter start time of the empty FC chamber in seconds',...
             'Sample', [1 50]);
        start_time = str2num(x{:});
        start_frame = TimeToFrame([folder '/' file],1,(start_time+10)*30,start_time);
%         pause(1e-3);
%         msgbox('Please wait while camera noise is estimated using the video of empty FC chamber');
        
        info_empty.filename = fullfile(folder,file);
        info_empty.start_idx = start_frame;
        savefile = [handles.folder_name '/info_empty_chamber.mat'];
         save(savefile,'info_empty');
%         thr = GetThreshold(info);
    case 'No'
        x = inputdlg('Enter threshold value (default 1.5)',...
             'Sample', [1 50]);
        thr = str2num(x{:});
        info_empty.thr = thr;
         savefile = [handles.folder_name '/info_empty_chamber.mat'];
         save(savefile,'info_empty');
end
Info_tmp = handles.Info;
% Go through and only keep elements that have a filename field
cntr = 1;
for i=1:numel(Info_tmp)
    if(~isempty(Info_tmp(i).filename))
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
            disp(['FC Initializations saved to ' savefile]);
            
        case 'No'
            uicontrol(hObject);
            return
        case 'Cancel'
            uicontrol(hObject);
            return
    end
else
    save(savefile,'Info');
    disp(['FC Initializations saved to ' savefile]);
end

button = questdlg('Do you want to batch process these files now or later?','Process now?','Now','Later','Later');
switch button
    case 'Now'
       h = msgbox('Submitting all files for batch processing. Please look at the MATLAB command window for progress of your analysis. This GUI will now exit in 10 seconds.');
       pause(10);
       delete(h);
       delete(handles.figure1);
       pause(1e-3);
        FCBatch(handles.folder_name);
        
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

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
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Selected','on');

pause(1e-3)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
try
    Mouse = ~strcmp(info.Tag,'na');
    
catch
    errordlg('You must enter a label for the mouse. (na = no mouse)','Bad Input','modal')
    set(handles.pushbutton2,'Enable','on');
    uicontrol(hObject)
    return
end
if(Mouse)
    if(~isfield(info,'Tag') || isempty(info.Tag))
        errordlg('You must enter a tag for the mouse','Bad Input','modal')
        set(handles.pushbutton2,'Enable','on');
        uicontrol(hObject)
        return
    end
end
if(isempty(info.start_time))
    errordlg('You must enter a time when mouse is placed in the box','Bad Input','modal')
    set(handles.pushbutton2,'Enable','on');
    uicontrol(hObject)
    return
end
h = msgbox('Please wait while determining frame #. This message will self destruct');
if(~isfield(info,'start_frame') || isempty(info.start_frame))
    % Video recorded at <30fps - use the start time to gauge how many
    % frames to read
    
    vidname = [handles.folder_name '/' handles.curr_file];
    
    start_frame = TimeToFrame(vidname,1,(info.start_time+10)*30,info.start_time);
    set(handles.text3,'String',['Frame # ' num2str(start_frame)]);
else    
    set(handles.text3,'String',['Frame # ' num2str(info.start_frame)]);
    
end
if(start_frame==-1)
    handles.Info(idx).Tag = 'na';
    handles.Info(idx).Mouse = 0;
    errordlg('Start frame not found. This file will be skipped','Start frame invalid','modal');
    uicontrol(hObject)
    return
end
vidname = [handles.folder_name '/' handles.curr_file];

handles.Info(idx).start_idx = start_frame;

handles.Info(idx).filename = vidname;
delete(h);
set(handles.pushbutton2,'Enable','on');
set(handles.pushbutton2,'Selected','off');
guidata(hObject,handles);
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
s=get(hObject,'String');
% Convert from min:sec to seconds
handles.Info(idx).duration_str = s;

handles.Info(idx).duration = str2num(s)*60;
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
handles.Info(idx).Tag = get(hObject,'String');
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
