function varargout = SocialGUI(varargin)
warning off
%SocialGUI M-file for SocialGUI.fig
%      SocialGUI, by itself, creates a new SocialGUI or raises the existing
%      singleton*.
%
%      H = SocialGUI returns the handle to a new SocialGUI or the handle to
%      the existing singleton*.
%
%      SocialGUI('Property','Value',...) creates a new SocialGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to SocialGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SocialGUI('CALLBACK') and SocialGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SocialGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SocialGUI

% Last Modified by GUIDE v2.5 18-Aug-2014 15:12:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SocialGUI_OpeningFcn, ...
    'gui_OutputFcn',  @SocialGUI_OutputFcn, ...
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


% --- Executes just before SocialGUI is made visible.
function SocialGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for SocialGUI
handles.output = hObject;
if(isempty(which('mmread')))
    addpath('../mmread');
end
if(isempty(which('inpaint_nans')))
    addpath('../Inpaint_nans');
end
% Update handles structure

guidata(hObject, handles);

% UIWAIT makes SocialGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SocialGUI_OutputFcn(hObject, eventdata, handles)
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
     set(handles.edit5,'String',[]);
        set(handles.edit9,'String',[]);
        set(handles.edit7,'String',[]);
        set(handles.edit8,'String',[]);
        set(handles.edit13,'String',[]);
        set(handles.edit14,'String',[]);
        set(handles.edit15,'String',[]);
        set(handles.edit16,'String',[]);
        set(handles.text15,'String','Frame #');
        set(handles.text16,'String','Frame #');
    set(handles.text23,'String','Frame #');
        set(handles.text24,'String','Frame #');
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
end

if(strcmp(selection,'normal'))
    set(handles.pushbutton6,'Enable','on');
    % Gray out fields that are not set yet
    if(idx>numel(handles.Info))
           set(handles.edit5,'String',[]);
        set(handles.edit9,'String',[]);
        set(handles.edit7,'String',[]);
        set(handles.edit8,'String',[]);
        set(handles.edit13,'String',[]);
        set(handles.edit14,'String',[]);
         set(handles.edit15,'String',[]);
        set(handles.edit16,'String',[]);
        set(handles.text15,'String','Frame #');
        set(handles.text16,'String','Frame #');
    set(handles.text23,'String','Frame #');
        set(handles.text24,'String','Frame #');
        set(handles.checkbox5,'Value',0);
        set(handles.checkbox6,'Value',0);
        set(handles.checkbox7,'Value',0);
        set(handles.checkbox8,'Value',0);
        set(handles.checkbox9,'Value',0);
        set(handles.checkbox10,'Value',0);
        set(handles.checkbox11,'Value',0);
        set(handles.checkbox12,'Value',0);
    else
        
        % Update fields of labels
        if(isfield(handles.Info(idx),'LeftTag'))
            LeftMouse = ~strcmp(handles.Info(idx).LeftTag,'na');
            handles.Info(idx).LeftMouse = LeftMouse;
            if(LeftMouse)
          try
                    set(handles.edit5,'String',handles.Info(idx).LeftTag);
          catch
                    set(handles.edit5,'String',[]);
          end
          
            end
        end
        if(isfield(handles.Info(idx),'RightTag'))
            RightMouse = ~strcmp(handles.Info(idx).RightTag,'na');
            handles.Info(idx).RightMouse = RightMouse;
            if(RightMouse)
                try
                    set(handles.edit9,'String',handles.Info(idx).RightTag);
                catch
                    set(handles.edit9,'String',[]);
                end
                
            end
        end
             
      
        try
            set(handles.edit7,'String',handles.Info(idx).start_time1_str);
        catch
            set(handles.edit7,'String',[]);
        end
        
        
        try
            set(handles.edit8,'String',handles.Info(idx).end_time1_str);
        catch
            set(handles.edit8,'String',[]);
        end
        
        try
            set(handles.edit13,'String',handles.Info(idx).start_time2_str);
        catch
            set(handles.edit13,'String',[]);
        end
        
        try
            set(handles.edit14,'String',handles.Info(idx).end_time2_str);
        catch
            set(handles.edit14,'String',[]);
        end
         try
            set(handles.edit15,'String',num2str(handles.Info(idx).box_W));
        catch
            set(handles.edit15,'String',[]);
         end
        try
            set(handles.edit16,'String',num2str(handles.Info(idx).box_L));
        catch
            set(handles.edit16,'String',[]);
        end
        try
            set(handles.text15,'String',['Frame # ' num2str(handles.Info(idx).start_idx1)]);
        catch
            set(handles.text15,'String',[]);
        end
        try
            set(handles.text16,'String',['Frame # ' num2str(handles.Info(idx).end_idx1)]);
        catch
            set(handles.text16,'String',[]);
        end
        try
            set(handles.text23,'String',['Frame # ' num2str(handles.Info(idx).start_idx2)]);
        catch
            set(handles.text23,'String',[]);
        end
        try
            set(handles.text24,'String',['Frame # ' num2str(handles.Info(idx).end_idx2)]);
        catch
            set(handles.text24,'String',[]);
        end
        set(handles.checkbox5,'Value',0);
        set(handles.checkbox6,'Value',0);
        set(handles.checkbox7,'Value',0);
        set(handles.checkbox8,'Value',0);
        set(handles.checkbox9,'Value',0);
        set(handles.checkbox10,'Value',0);
        set(handles.checkbox11,'Value',0);
        set(handles.checkbox12,'Value',0);
        try
            set(handles.checkbox5,'Value',handles.Info(idx).Novel(1));
        end
        try
            set(handles.checkbox6,'Value',handles.Info(idx).Novel(2));
        end
        try
            set(handles.checkbox7,'Value',handles.Info(idx).Novel(3));
        end
        try
            set(handles.checkbox8,'Value',handles.Info(idx).Novel(4));
        end
        try
            set(handles.checkbox9,'Value',handles.Info(idx).Novel(5));
        end
        try
            set(handles.checkbox10,'Value',handles.Info(idx).Novel(6));
        end
        try
            set(handles.checkbox11,'Value',handles.Info(idx).Novel(7));
        end
        try
            set(handles.checkbox12,'Value',handles.Info(idx).Novel(8));
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
    I = info.start_frame1;
    LeftMouse = info.LeftMouse;    
    RightMouse = info.RightMouse;
    h=figure('Name','First 10 minute interval')
    hax_fig = gca;
    imshow(info.start_frame1,'Parent',hax_fig);
    title('First 10 minutes');
    hfig = imgcf;
    hax = imgca;
    hold all
    if(LeftMouse)
        % Show trace of the box
        
        if(isfield(info.ROIs,'surface_top') && ~isempty(info.ROIs.surface_top))
            B = bwboundaries(info.ROIs.surface_top);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            end
        end
        
        if(isfield(info.ROIs,'left_chamber_top') && ~isempty(info.ROIs.left_chamber_top))
            B = bwboundaries(info.ROIs.left_chamber_top);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        
        if(isfield(info.ROIs,'right_chamber_top') && ~isempty(info.ROIs.right_chamber_top))
            B = bwboundaries(info.ROIs.right_chamber_top);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        try
            BW = info.ROIs.surface_top - info.ROIs.left_chamber_top - info.ROIs.right_chamber_top;
            BW = logical(BW);
            handles.Info(curr_idx).ROIs.middle_chamber_top = BW;
            B = bwboundaries(BW);
            for k=1:length(B)
                boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
            end
        end
        % Show the metal and glass objects in left box
        
            if(isfield(info.ROIs,'BWobject1') && ~isempty(info.ROIs.BWobject1))
                B = bwboundaries(info.ROIs.BWobject1);
                for k = 1:length(B)
                    boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
                end
            end
            if(isfield(info.ROIs,'BWobject2') && ~isempty(info.ROIs.BWobject2))
                B = bwboundaries(info.ROIs.BWobject2);
                for k = 1:length(B)
                    boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
                end
            end
       
    end
      if(RightMouse)
        % Show trace of the box
        
        if(isfield(info.ROIs,'surface_bottom') && ~isempty(info.ROIs.surface_bottom))
            B = bwboundaries(info.ROIs.surface_bottom);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            end
        end
        
        
        if(isfield(info.ROIs,'left_chamber_bottom') && ~isempty(info.ROIs.left_chamber_bottom))
            B = bwboundaries(info.ROIs.left_chamber_bottom);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        
        if(isfield(info.ROIs,'right_chamber_bottom') && ~isempty(info.ROIs.right_chamber_bottom))
            B = bwboundaries(info.ROIs.right_chamber_bottom);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        try
            BW = info.ROIs.surface_bottom - info.ROIs.left_chamber_bottom - info.ROIs.right_chamber_bottom;
            BW = logical(BW);
            handles.Info(curr_idx).ROIs.middle_chamber_bottom = BW;
            B = bwboundaries(BW);
            for k=1:length(B)
                boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
            end
        end
        % Show the metal and glass objects in left box
        
            if(isfield(info.ROIs,'BWobject5') && ~isempty(info.ROIs.BWobject5))
                B = bwboundaries(info.ROIs.BWobject5);
                for k = 1:length(B)
                    boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
                end
            end
            if(isfield(info.ROIs,'BWobject6') && ~isempty(info.ROIs.BWobject6))
                B = bwboundaries(info.ROIs.BWobject6);
                for k = 1:length(B)
                    boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
                end
            end
       
      end
    
  % Second 10 minute interval
   h=figure('Name','Second 10 minute interval');
    hax_fig = gca;
    imshow(info.start_frame2,'Parent',hax_fig);

    hfig = imgcf;
    hax = imgca;
    hold all
    if(LeftMouse)
        % Show trace of the box
        
        if(isfield(info.ROIs,'surface_top') && ~isempty(info.ROIs.surface_top))
            B = bwboundaries(info.ROIs.surface_top);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            end
        end
        
       
        if(isfield(info.ROIs,'left_chamber_top') && ~isempty(info.ROIs.left_chamber_top))
            B = bwboundaries(info.ROIs.left_chamber_top);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        
        if(isfield(info.ROIs,'right_chamber_top') && ~isempty(info.ROIs.right_chamber_top))
            B = bwboundaries(info.ROIs.right_chamber_top);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        try
            BW = info.ROIs.surface_top - info.ROIs.left_chamber_top - info.ROIs.right_chamber_top;
            BW = logical(BW);
            handles.Info(curr_idx).ROIs.middle_chamber_top = BW;
            B = bwboundaries(BW);
            for k=1:length(B)
                boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
            end
        end
        % Show the metal and glass objects in left box
        
            if(isfield(info.ROIs,'BWobject3') && ~isempty(info.ROIs.BWobject3))
                B = bwboundaries(info.ROIs.BWobject3);
                for k = 1:length(B)
                    boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
                end
            end
            if(isfield(info.ROIs,'BWobject4') && ~isempty(info.ROIs.BWobject4))
                B = bwboundaries(info.ROIs.BWobject4);
                for k = 1:length(B)
                    boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
                end
            end
       
    end
      if(RightMouse)
        % Show trace of the box
        
        if(isfield(info.ROIs,'surface_bottom') && ~isempty(info.ROIs.surface_bottom))
            B = bwboundaries(info.ROIs.surface_bottom);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            end
        end
        
      
        if(isfield(info.ROIs,'left_chamber_bottom') && ~isempty(info.ROIs.left_chamber_bottom))
            B = bwboundaries(info.ROIs.left_chamber_bottom);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        
        if(isfield(info.ROIs,'right_chamber_bottom') && ~isempty(info.ROIs.right_chamber_bottom))
            B = bwboundaries(info.ROIs.right_chamber_bottom);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        try
            BW = info.ROIs.surface_bottom - info.ROIs.left_chamber_bottom - info.ROIs.right_chamber_bottom;
            BW = logical(BW);
            handles.Info(curr_idx).ROIs.middle_chamber_bottom = BW;
            B = bwboundaries(BW);
            for k=1:length(B)
                boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
            end
        end
        % Show the metal and glass objects in left box
        
            if(isfield(info.ROIs,'BWobject7') && ~isempty(info.ROIs.BWobject7))
                B = bwboundaries(info.ROIs.BWobject7);
                for k = 1:length(B)
                    boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
                end
            end
            if(isfield(info.ROIs,'BWobject8') && ~isempty(info.ROIs.BWobject8))
                B = bwboundaries(info.ROIs.BWobject8);
                for k = 1:length(B)
                    boundary = B{k};
                    plot(hax,boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
                end
            end
       
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
    if(~isempty(Info_tmp(i).filename) && ~isempty(Info_tmp(i).start_idx1))
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
            disp(['Social interaction initializations saved to ' savefile]);
            
       
    end
else
    save(savefile,'Info');
    disp(['Social interaction initializations saved to ' savefile]);
end
button = questdlg('Do you want to batch process these files now or later?','Process now?','Now','Later','Later');
switch button
    case 'Now'
        h = msgbox('Submitting all files for batch processing. ');
        pause(2);
        try
            delete(h);
        end
        SocialBatch(handles.folder_name);
        
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
handles.Info(idx).LeftTag = choice;
if(~strcmp(choice,'na'))
    handles.Info(idx).LeftMouse = 1;
 
else
    handles.Info(idx).LeftMouse = 0;
  
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
handles.Info(idx).start_time1_str = s;
handles.Info(idx).start_time1 = minute*60+sec;
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
handles.Info(idx).end_time1_str = s;
handles.Info(idx).end_time1 = minute*60+sec;
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
    LeftMouse = info.LeftMouse;
    RightMouse = info.RightMouse;
   
catch
    errordlg('You must enter a label for left and right mouse. (na = no mouse)','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end


if(isempty(info.start_time1))
    errordlg('You must enter a start time for the first 10 minute interval','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end

if(isempty(info.start_time2))
    errordlg('You must enter a start time for the second 10 minute interval','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end
if(isempty(info.end_time1))
    errordlg('You must enter an end time for the first 10 minute interval','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end
if(isempty(info.end_time2))
    errordlg('You must enter an end time for the first 10 minute interval','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end

h = msgbox('Please wait while determining frame #. This message will self destruct');

    % Video recorded at <30fps - use the start time to gauge how many
    % frames to read.
    % Assume that fps = 30. Will get a more exact frame number during the
    % actual processing. Here, in the GUI, a rough estimate is enough
    % otherwise the user will sit at the computer for > 1-2 minutes per
    % video.
    
    vidname = [handles.folder_name '/' handles.curr_file];
    start_frame1 = info.start_time1*30;
    start_frame2 = info.start_time2*30;
    end_frame1 = info.end_time1*30;
    end_frame2 = info.end_time2*30;
%     
%     start_frame1 = TimeToFrame(vidname,1,(info.start_time1+5)*30,info.start_time1);
%     set(handles.text15,'String',['Frame # ' num2str(start_frame1)]);
%     end_frame1 = TimeToFrame(vidname,start_frame1,(info.end_time1+5)*30,info.end_time1);
%     set(handles.text16,'String',['Frame # ' num2str(end_frame1)]);
%     
%     start_frame2 = TimeToFrame(vidname,end_frame1,(info.start_time2+5)*30,info.start_time2);
%     set(handles.text23,'String',['Frame # ' num2str(start_frame2)]);
%     
%     end_frame2 = TimeToFrame(vidname,start_frame2,(info.end_time2+5)*30,info.end_time2);
%     set(handles.text24,'String',['Frame # ' num2str(end_frame2)]);

% ROIs=InitializeSOR(vidname,ref_frame,info.Objects,LeftMouse,RightMouse);
handles.Info(idx).start_idx1 = start_frame1;
handles.Info(idx).start_idx2 = start_frame2;
handles.Info(idx).end_idx1 = end_frame1;
handles.Info(idx).end_idx2 = end_frame2;
        try
            set(handles.text15,'String',['Frame # ' num2str(handles.Info(idx).start_idx1)]);
        catch
            set(handles.text15,'String',[]);
        end
        try
            set(handles.text16,'String',['Frame # ' num2str(handles.Info(idx).end_idx1)]);
        catch
            set(handles.text16,'String',[]);
        end
        try
            set(handles.text23,'String',['Frame # ' num2str(handles.Info(idx).start_idx2)]);
        catch
            set(handles.text23,'String',[]);
        end
        try
            set(handles.text24,'String',['Frame # ' num2str(handles.Info(idx).end_idx2)]);
        catch
            set(handles.text24,'String',[]);
        end

vidname = [handles.folder_name '/' handles.curr_file];
V = mmread(vidname,start_frame1:start_frame1+50);
handles.Info(idx).start_frame1 = V(end).frames(20).cdata;

V = mmread(vidname,start_frame2:start_frame2+50);
handles.Info(idx).start_frame2 = V(end).frames(20).cdata;

% handles.Info(idx).ROIs = ROIs;
handles.Info(idx).filename = vidname;

delete(h);
if(isfield(handles.Info(idx),'Novel'))
    if(isempty(handles.Info(idx).Novel))
        handles.Info(idx).Novel = zeros(8,1);
    end
end
    
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
choice = questdlg('Draw free-hand or rectangle?','Top half, Left chamber ROI','Rectangle','Free-hand','Cancel','Rectangle');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hfree = imfreehand(hax);
        BW = hfree.createMask;
        handles.Info(idx).ROIs.left_chamber_top=BW;
        % Delete figure
        delete(hfig);
    case 'Rectangle'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.left_chamber_top = BW;
        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return
        
end
guidata(hObject,handles);
% --- Executes on button press in pushbutton11 - glass left
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or ellipse?','Top half, left object (0-10 min)','Ellipse','Free-hand','Cancel','Ellipse');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

switch choice
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject1 = hobject1.createMask;
       
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject1 = hobject1.createMask;

        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);
% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or ellipse?','Top half, right object (0-10 min)','Ellipse','Free-hand','Cancel','Ellipse');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

switch choice
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject2 = hobject1.createMask;
       
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject2 = hobject1.createMask;

        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or rectangle?','Right half of the box ROI','Rectangle','Free-hand','Cancel','Rectangle');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hfree = imfreehand(hax);
        BW = hfree.createMask;
        handles.Info(idx).ROIs.mask_right = BW;
        % Delete figure
        delete(hfig);
    case 'Rectangle'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.mask_right = BW;
        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return
        
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or ellipse?','Top half, left object (10-20 min)','Ellipse','Free-hand','Cancel','Ellipse');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

switch choice
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject3 = hobject1.createMask;
       
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject3 = hobject1.createMask;

        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or ellipse?','Top half, right object (10-20 min)','Ellipse','Free-hand','Cancel','Ellipse');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

switch choice
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject4 = hobject1.createMask;
       
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject4 = hobject1.createMask;

        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function pushbutton10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','on');


% --- Executes during object creation, after setting all properties.
function pushbutton11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','on');


% --- Executes during object creation, after setting all properties.
function pushbutton12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','on');


% --- Executes during object creation, after setting all properties.
function pushbutton13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','on');


% --- Executes during object creation, after setting all properties.
function pushbutton14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','on');


% --- Executes during object creation, after setting all properties.
function pushbutton15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','on');


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

set(handles.listbox3,'String',filename,...
    'Value',1)
set(handles.text11,'String',handles.folder_name)

% Update Info elements to have a ref image
disp('Please wait while info.mat is loaded into workspace');
h = msgbox('Please wait while loading videos. This message will self destruct');
t1 = clock;
for i=1:numel(Info)
    disp(['Loading ' num2str(i) ' of ' num2str(numel(Info))]);
    if(etime(clock,t1)>120)
        t1 = clock;
        continue
    end
    if(~isfield(Info(i),'ref_frame') || isempty(Info(i).ref_frame))
        V = mmread(Info(i).filename,Info(i).start_idx1);
        Info(i).start_frame1 = V(end).frames.cdata;
        
        V = mmread(Info(i).filename,Info(i).start_idx2);
        Info(i).start_frame2 = V(end).frames.cdata;
    end
    
end
delete(h);
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
choice = get(hObject,'String');
handles.Info(idx).RightTag = choice;
if(~strcmp(choice,'na'))
    handles.Info(idx).RightMouse = 1;
  
else
    handles.Info(idx).RightMouse = 0;
  
end

try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(idx).RightTag = get(hObject,'String');
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


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or rectangle?','Top half, surface of the box ROI','Rectangle','Free-hand','Cancel','Rectangle');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imfreehand(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_top = BW;
        delete(hfig);
    case 'Rectangle'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_top = BW;
        delete(hfig);
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or rectangle?','Right surface of the box ROI','Rectangle','Free-hand','Cancel','Rectangle');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imfreehand(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_right = BW;
        delete(hfig);
    case 'Rectangle'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_right = BW;
        delete(hfig);
end
guidata(hObject,handles);



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
handles.Info(idx).start_time2_str = s;
handles.Info(idx).start_time2 = minute*60+sec;
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
handles.Info(idx).end_time2_str = s;
handles.Info(idx).end_time2 = minute*60+sec;
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
handles.Info(handles.curr_idx).box_W = str2double(get(hObject,'String'));
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


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or rectangle?','Bottom half, left chamber ROI','Rectangle','Free-hand','Cancel','Rectangle');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hfree = imfreehand(hax);
        BW = hfree.createMask;
        handles.Info(idx).ROIs.left_chamber_bottom=BW;
        % Delete figure
        delete(hfig);
    case 'Rectangle'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.left_chamber_bottom = BW;
        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return
        
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or ellipse?','Bottom half, left object (0-10 min)','Ellipse','Free-hand','Cancel','Ellipse');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

switch choice
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject5 = hobject1.createMask;
       
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject5 = hobject1.createMask;

        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or ellipse?','Top half, right object (0-10 min)','Ellipse','Free-hand','Cancel','Ellipse');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

switch choice
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject6 = hobject1.createMask;
       
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject6 = hobject1.createMask;

        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Draw free-hand or rectangle?','Bottom half, surface of the box ROI','Rectangle','Free-hand','Cancel','Rectangle');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imfreehand(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_bottom = BW;
        delete(hfig);
    case 'Rectangle'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_bottom = BW;
        delete(hfig);
end
guidata(hObject,handles);
% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Draw free-hand or rectangle?','Top half, Right chamber ROI','Rectangle','Free-hand','Cancel','Rectangle');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hfree = imfreehand(hax);
        BW = hfree.createMask;
        handles.Info(idx).ROIs.right_chamber_top=BW;
        % Delete figure
        delete(hfig);
    case 'Rectangle'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.right_chamber_top = BW;
        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return
        
end
guidata(hObject,handles);
% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or rectangle?','Bottom half, right chamber ROI','Rectangle','Free-hand','Cancel','Rectangle');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
switch choice
    case 'Free-hand'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hfree = imfreehand(hax);
        BW = hfree.createMask;
        handles.Info(idx).ROIs.right_chamber_bottom=BW;
        % Delete figure
        delete(hfig);
    case 'Rectangle'
        
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame1,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.right_chamber_bottom = BW;
        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return
        
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or ellipse?','Bottom half, right object (10-20 min)','Ellipse','Free-hand','Cancel','Ellipse');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

switch choice
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject8 = hobject1.createMask;
       
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject8 = hobject1.createMask;

        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or ellipse?','Bottom half, left object (10-20 min)','Ellipse','Free-hand','Cancel','Ellipse');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);

switch choice
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject7 = hobject1.createMask;
       
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.start_frame2,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject7 = hobject1.createMask;

        delete(hfig);
    case 'Cancel'
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
state = get(hObject,'Value');
if(state)
    handles.Info(handles.curr_idx).Novel(1) = 1;
end
guide(hObject,handles);
% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
state = get(hObject,'Value');
if(state)
    handles.Info(handles.curr_idx).Novel(2) = 1;
end
guide(hObject,handles);

% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7

state = get(hObject,'Value');
if(state)
    handles.Info(handles.curr_idx).Novel(3) = 1;
end
guide(hObject,handles);
% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
state = get(hObject,'Value');
if(state)
    handles.Info(handles.curr_idx).Novel(4) = 1;
end
guide(hObject,handles);

% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
state = get(hObject,'Value');
if(state)
    handles.Info(handles.curr_idx).Novel(5) = 1;
end
guide(hObject,handles);

% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10

state = get(hObject,'Value');
if(state)
    handles.Info(handles.curr_idx).Novel(6) = 1;
end
guide(hObject,handles);
% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
state = get(hObject,'Value');
if(state)
    handles.Info(handles.curr_idx).Novel(7) = 1;
end
guide(hObject,handles);

% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12
state = get(hObject,'Value');
if(state)
    handles.Info(handles.curr_idx).Novel(8) = 1;
end
guide(hObject,handles);


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Social(handles.Info(handles.curr_idx),'DISPLAY',1);



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double
handles.Info(handles.curr_idx).box_L = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pushbutton7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
