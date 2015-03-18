function varargout = SORGUI(varargin)
warning off
%SORGUI M-file for SORGUI.fig
%      SORGUI, by itself, creates a new SORGUI or raises the existing
%      singleton*.
%
%      H = SORGUI returns the handle to a new SORGUI or the handle to
%      the existing singleton*.
%
%      SORGUI('Property','Value',...) creates a new SORGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to SORGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SORGUI('CALLBACK') and SORGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SORGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SORGUI

% Last Modified by GUIDE v2.5 17-Aug-2014 21:09:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SORGUI_OpeningFcn, ...
    'gui_OutputFcn',  @SORGUI_OutputFcn, ...
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


% --- Executes just before SORGUI is made visible.
function SORGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for SORGUI
handles.output = hObject;
if(isempty(which('mmread')))
    addpath('../mmread');
end
if(isempty(which('inpaint_nans')))
    addpath('../Inpaint_nans');
end

% Update handles structure

guidata(hObject, handles);

% UIWAIT makes SORGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SORGUI_OutputFcn(hObject, eventdata, handles)
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
        set(handles.pushbutton12,'Enable','off');
 
        set(handles.pushbutton13,'Enable','off');
        set(handles.pushbutton14,'Enable','off');
        set(handles.pushbutton15,'Enable','off');
 
        set(handles.pushbutton18,'Enable','off');
        set(handles.pushbutton19,'Enable','off');
%         set(handles.edit5,'String',[]);
%         set(handles.edit6,'String',[]);
        
        set(handles.edit8,'String',[]);
        set(handles.edit9,'String',[]);
        set(handles.edit10,'String',[]);
        
        
         set(handles.edit13,'String',[]);
         set(handles.edit14,'String',[]);
         set(handles.edit16,'String',[]);
         set(handles.edit17,'String',[]);
         
        
        set(handles.text16,'String','Frame #');
        set(handles.popupmenu2,'Value',1);
        set(handles.popupmenu6,'Value',1);
        set(handles.checkbox5,'Value',0);
        set(handles.checkbox6,'Value',0);
        set(handles.checkbox7,'Value',0);
        set(handles.checkbox8,'Value',0);
    else
        % Gray out fields that are not set yet
        if(~isfield(handles.Info(idx),'filename') || isempty(handles.Info(idx).filename))
            set(handles.pushbutton10,'Enable','off');
            set(handles.pushbutton11,'Enable','off');
            set(handles.pushbutton12,'Enable','off');
           
            set(handles.pushbutton13,'Enable','off');
            set(handles.pushbutton14,'Enable','off');
            set(handles.pushbutton15,'Enable','off');
            
            set(handles.pushbutton18,'Enable','off');
            set(handles.pushbutton19,'Enable','off');
        else
            set(handles.pushbutton10,'Enable','on');
            set(handles.pushbutton11,'Enable','on');
            set(handles.pushbutton12,'Enable','on');
            
            set(handles.pushbutton13,'Enable','on');
            set(handles.pushbutton14,'Enable','on');
            set(handles.pushbutton15,'Enable','on');
            
            set(handles.pushbutton18,'Enable','on');
            set(handles.pushbutton19,'Enable','on');
        end
        
        if(isfield(handles.Info(idx),'start_idx'))
            set(handles.text16,'String',['Frame # ' num2str(handles.Info(idx).start_idx)]);
        end
    end
end

if(strcmp(selection,'normal'))
    set(handles.pushbutton6,'Enable','on');
    % Gray out fields that are not set yet
    if(idx>numel(handles.Info))
        set(handles.pushbutton10,'Enable','off');
        set(handles.pushbutton11,'Enable','off');
        set(handles.pushbutton12,'Enable','off');
        
        set(handles.pushbutton13,'Enable','off');
        set(handles.pushbutton14,'Enable','off');
        set(handles.pushbutton15,'Enable','off');
        
        set(handles.pushbutton18,'Enable','off');
        set(handles.pushbutton19,'Enable','off');
%         set(handles.edit5,'Enable','on')
%         set(handles.edit6,'Enable','on')
        set(handles.edit9,'Enable','on')
        set(handles.edit10,'Enable','on')
        set(handles.checkbox5,'Value',0);
        set(handles.checkbox6,'Value',0);
        set(handles.checkbox7,'Value',0);
        set(handles.checkbox8,'Value',0);
        
        set(handles.edit8,'Enable','on')
        set(handles.popupmenu2,'Enable','on')
        set(handles.popupmenu6,'Enable','on')
        
%         set(handles.edit5,'String',[]);
%         set(handles.edit6,'String',[]);
        
        set(handles.edit8,'String',[]);
        set(handles.edit9,'String',[]);
        set(handles.edit10,'String',[]);
        
        
         set(handles.edit13,'String',[]);
         set(handles.edit14,'String',[]);
         set(handles.edit16,'String',[]);
         set(handles.edit17,'String',[]);
         
        set(handles.popupmenu2,'Value',1);
        set(handles.popupmenu6,'Value',1);
        
        set(handles.text16,'String','Frame #');
    else
        if(~isfield(handles.Info(idx),'filename') || isempty(handles.Info(idx).filename))
            set(handles.pushbutton10,'Enable','off');
            set(handles.pushbutton11,'Enable','off');
            set(handles.pushbutton12,'Enable','off');
            
            set(handles.pushbutton13,'Enable','off');
            set(handles.pushbutton14,'Enable','off');
            set(handles.pushbutton15,'Enable','off');
            
            set(handles.pushbutton18,'Enable','off');
            set(handles.pushbutton19,'Enable','off');
%             set(handles.edit5,'String',[]);
%             set(handles.edit6,'String',[]);
            set(handles.edit9,'String',[]);
            set(handles.edit10,'String',[]);
            
            
%             set(handles.edit5,'Enable','on');
%             set(handles.edit6,'Enable','on');
            set(handles.edit9,'Enable','on');
            set(handles.edit10,'Enable','on');
            
        else
            set(handles.pushbutton10,'Enable','on');
            set(handles.pushbutton11,'Enable','on');
            set(handles.pushbutton12,'Enable','on');
            
            set(handles.pushbutton13,'Enable','on');
            set(handles.pushbutton14,'Enable','on');
            set(handles.pushbutton15,'Enable','on');
            
            set(handles.pushbutton18,'Enable','on');
            set(handles.pushbutton19,'Enable','on');
%             set(handles.edit5,'Enable','on');
%             set(handles.edit6,'Enable','on');
            set(handles.edit9,'Enable','on');
            set(handles.edit10,'Enable','on');
            
        end
        % Update fields of labels
        if(isfield(handles.Info(idx),'LeftTag'))
            LeftMouse = ~strcmp(handles.Info(idx).LeftTag,'na');
            handles.Info(idx).LeftMouse = LeftMouse;
            if(handles.Info(idx).LeftMouse)
                if(isfield(handles.Info(idx),'LeftSessionValue') && ~isempty(handles.Info(idx).LeftSessionValue))
                    set(handles.popupmenu2,'Value',handles.Info(idx).LeftSessionValue)
                else
                    set(handles.popupmenu2,'Value',1)
                end
                if(isfield(handles.Info(idx),'LeftObjects'))
                    if(isempty(handles.Info(idx).LeftObjects))
                        %             minVal = get(handles.checkbox4,'Min');
                        %             set(handles.checkbox4,'Value',minVal);
                        %             set(handles.checkbox4,'Value',minVal);
                        set(handles.popupmenu2,'Value',1)
                        set(handles.pushbutton10,'Enable','off');
                        set(handles.pushbutton11,'Enable','off');
                        set(handles.pushbutton12,'Enable','off');
                        
                        set(handles.pushbutton18,'Enable','off');
                        
                    else
                        LeftMouse = ~strcmp(handles.Info(idx).LeftTag,'na');
                        
                        if(LeftMouse)
                            set(handles.pushbutton10,'Enable','on');
                            set(handles.pushbutton18,'Enable','on');
                            if(handles.Info(idx).LeftObjects)
                                set(handles.pushbutton11,'Enable','on');
                                set(handles.pushbutton12,'Enable','on');
                                
                            end
                        else
                            set(handles.pushbutton10,'Enable','off');
                            set(handles.pushbutton11,'Enable','off');
                            set(handles.pushbutton12,'Enable','off');
                            
                            set(handles.pushbutton18,'Enable','off');
                        end
                    end
                end
                set(handles.edit9,'Enable','on');
                
                set(handles.popupmenu2,'Enable','on');
%                 if(isfield(handles.Info(idx),'LeftTag'))
%                     set(handles.edit5,'String',handles.Info(idx).LeftTag);
%                 end
                if(isfield(handles.Info(idx),'LeftTag'))
                    set(handles.edit9,'String',handles.Info(idx).LeftTag);
                end
                
            else
                set(handles.edit9,'String',[]);
                
                set(handles.edit9,'Enable','off');
                
                set(handles.popupmenu2,'Value',1);
                set(handles.popupmenu2,'Enable','off');
%                 set(handles.edit5,'String',handles.Info(idx).LeftTag);
            end
            
        end
        
        
        
        if(isfield(handles.Info(idx),'RightTag'))
            RightMouse = ~strcmp(handles.Info(idx).RightTag,'na');
            handles.Info(idx).RightMouse = RightMouse;
            if(handles.Info(idx).RightMouse)
                if(isfield(handles.Info(idx),'RightSessionValue') && ~isempty(handles.Info(idx).RightSessionValue))
                    set(handles.popupmenu6,'Value',handles.Info(idx).RightSessionValue)
                else
                    set(handles.popupmenu6,'Value',1)
                end
                set(handles.edit10,'Enable','on');
                
                set(handles.popupmenu6,'Enable','on');
                if(isfield(handles.Info(idx),'RightTag'))
                    set(handles.edit10,'String',handles.Info(idx).RightTag);
                end
                
%                 set(handles.edit6,'String',handles.Info(idx).RightTag);
                
                
                
                if(isfield(handles.Info(idx),'RightObjects'))
                    if(isempty(handles.Info(idx).RightObjects))
                        %             minVal = get(handles.checkbox4,'Min');
                        %             set(handles.checkbox4,'Value',minVal);
                        %             set(handles.checkbox4,'Value',minVal);
                        set(handles.popupmenu6,'Value',1)
                        set(handles.pushbutton13,'Enable','off');
                        set(handles.pushbutton14,'Enable','off');
                        set(handles.pushbutton15,'Enable','off');
                        
                        set(handles.pushbutton19,'Enable','off');
                        
                    else
                        
                        RightMouse = ~strcmp(handles.Info(idx).RightTag,'na');
                        if(RightMouse)
                            set(handles.pushbutton13,'Enable','on');
                            set(handles.pushbutton19,'Enable','on');
                            if(handles.Info(idx).RightObjects)
                                set(handles.pushbutton14,'Enable','on');
                                set(handles.pushbutton15,'Enable','on');
                                
                            end
                        else
                            set(handles.pushbutton13,'Enable','off');
                            set(handles.pushbutton14,'Enable','off');
                            set(handles.pushbutton15,'Enable','off');
                            
                            set(handles.pushbutton19,'Enable','off');
                        end
                        
                    end
                    
                end
            else
                set(handles.edit10,'String',[]);
                
                set(handles.popupmenu6,'Value',1);
                set(handles.edit10,'Enable','off');
                
                set(handles.popupmenu6,'Enable','off');
%                 set(handles.edit6,'String',handles.Info(idx).RightTag);
            end
        end
        
        if(isfield(handles.Info(idx),'start_time'))
            set(handles.edit8,'String',handles.Info(idx).start_time_str);
        end
         if(isfield(handles.Info(idx),'duration'))
            set(handles.edit13,'String',handles.Info(idx).duration_str);
         end
            if(isfield(handles.Info(idx),'dimensions_L'))
            set(handles.edit14,'String',num2str(handles.Info(idx).dimensions_L));
            end
            
            if(isfield(handles.Info(idx),'dimensions_W'))
            set(handles.edit16,'String',num2str(handles.Info(idx).dimensions_W));
            end
            if(isfield(handles.Info(idx),'perimeter'))
            set(handles.edit17,'String',num2str(handles.Info(idx).perimeter));
        end
        
        if(isfield(handles.Info(idx),'start_idx'))
            set(handles.text16,'String',['Frame # ' num2str(handles.Info(idx).start_idx)]);
        end
    end
    set(handles.checkbox5,'Value',0);
    set(handles.checkbox6,'Value',0);
    set(handles.checkbox7,'Value',0);
    set(handles.checkbox8,'Value',0);
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
    LeftMouse = ~strcmp(info.LeftTag,'na');
    RightMouse = ~strcmp(info.RightTag,'na');
    h=figure;
    hax_fig = gca;
    imshow(info.ref_frame,'Parent',hax_fig);
    hfig = imgcf;
    hax = imgca;
    hold all
    if(LeftMouse)
        % Show trace of the box
        if(isfield(info.ROIs,'mask_left') && ~isempty(info.ROIs.mask_left))
            B = bwboundaries(info.ROIs.mask_left);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        if(isfield(info.ROIs,'surface_left') && ~isempty(info.ROIs.surface_left))
            B = bwboundaries(info.ROIs.surface_left);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            end
        end
        % Show the metal and glass objects in left box
        if(info.LeftObjects)
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
    end
    
    if(RightMouse)
        % Show trace of the box
        if(isfield(info.ROIs,'mask_right') && ~isempty(info.ROIs.mask_right))
            B = bwboundaries(info.ROIs.mask_right);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            end
        end
        if(isfield(info.ROIs,'surface_right') && ~isempty(info.ROIs.surface_right))
            B = bwboundaries(info.ROIs.surface_right);
            for k = 1:length(B)
                boundary = B{k};
                plot(hax,boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            end
        end
        % Show the metal and glass objects in left box
        if(info.RightObjects)
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
    if(~isempty(Info_tmp(i).filename))
        % Fix filename if it was done on non-linux computer
        filename = Info_tmp(i).filename;
%         if(filename(1)~='/')
%             [pre post] = fileparts(filename);
%             % Replace the drive letter with /media/behavior
%             filename(1:3) = [];
%             filename = ['/media/behavior/' filename];
%             % Replace '\' with '/'
%             idx = strfind(filename,'\');
%             filename(idx) = '/';
%         end
%         Info_tmp(i).filename = filename;
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
            disp(['SOR Initializations saved to ' savefile]);
            
       
    end
else
    save(savefile,'Info');
    disp(['SOR Initializations saved to ' savefile]);
end
button = questdlg('Do you want to batch process these files now or later?','Process now?','Now','Later','Later');
switch button
    case 'Now'
        h = msgbox('Submitting all files for batch processing. ');
      
        pause(2);
        delete(h)
        SORBatch(handles.folder_name);
        
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
    set(handles.edit9,'Enable','on');
    
    set(handles.popupmenu2,'Enable','on');
else
    handles.Info(idx).LeftMouse = 0;
    set(handles.edit9,'Enable','off');
    
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
handles.Info(idx).RightTag = choice;
if(~strcmp(choice,'na'))
    handles.Info(idx).RightMouse = 1;
    set(handles.edit10,'Enable','on');
    
    set(handles.popupmenu6,'Enable','on');
else
    handles.Info(idx).RightMouse = 0;
    set(handles.edit10,'Enable','off');
    
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
set(handles.pushbutton12,'Enable','off');

set(handles.pushbutton13,'Enable','off');
set(handles.pushbutton14,'Enable','off');
set(handles.pushbutton15,'Enable','off');

set(handles.pushbutton18,'Enable','on');
set(handles.pushbutton19,'Enable','on');
pause(1e-3)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
try
    LeftMouse = ~strcmp(info.LeftTag,'na');
    RightMouse = ~strcmp(info.RightTag,'na');
catch
    errordlg('You must enter a label for left and right mouse. (na = no mouse)','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end
if(LeftMouse)
    if(~isfield(info,'LeftTag') || isempty(info.LeftTag))
        errordlg('You must enter a label for left mouse','Bad Input','modal')
        set(handles.pushbutton6,'Enable','on');
        uicontrol(hObject)
        return
    end
    
    if(~isfield(info,'LeftObjects') || isempty(info.LeftObjects))
        errordlg('You must make a selection on session type for left mouse','Bad Input','modal')
        set(handles.pushbutton6,'Enable','on');
        uicontrol(hObject)
        return
    end
  
end
if(RightMouse)
    if(~isfield(info,'RightTag') || isempty(info.RightTag))
        errordlg('You must enter a tag number for right mouse','Bad Input','modal')
        set(handles.pushbutton6,'Enable','on');
        uicontrol(hObject)
        return
    end
   
    if(~isfield(info,'RightObjects') || isempty(info.RightObjects))
        errordlg('You must make a selection on session type for right mouse','Bad Input','modal')
        set(handles.pushbutton6,'Enable','on');
        uicontrol(hObject)
        return
    end
 
end

if(isempty(info.start_time))
    errordlg('You must enter a time when mouse is placed in the box','Bad Input','modal')
    set(handles.pushbutton6,'Enable','on');
    uicontrol(hObject)
    return
end
set(hObject,'Enable','off');
set(hObject,'Selected','on');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);


h = msgbox('Please wait while determining frame # and background. This may take several minutes. This message will self destruct');
if(~isfield(info,'start_frame') || isempty(info.start_frame))
    % Video recorded at <30fps - use the start time to gauge how many
    % frames to read
    
    vidname = [handles.folder_name '/' handles.curr_file];
  
    
    start_frame = TimeToFrame(vidname,1,(info.start_time+10)*30,info.start_time);
    set(handles.text16,'String',['Frame # ' num2str(start_frame)]);
else
    
    set(handles.text16,'String',['Frame # ' num2str(info.start_frame)]);
    
end
if(start_frame==-1)
    errordlg('Start frame not found within the first 5000 frames. Make a note of this file and manually adjust','Reference frame invalid','modal');
    uicontrol(hObject)
    return
end
%%%%%%%%%%%%%%%%%%%%%%
vidname = [handles.folder_name '/' handles.curr_file];

if(~isfield(handles.Info(idx),'frames') || isempty(handles.Info(idx).frames))
    frames = mmcount(vidname);
    if(isnan(frames))
        vid = VideoReader(vidname);
        
        if(isempty(vid.NumberOfFrames))
            read(vid,inf);
        end
        
        frames = vid.NumberOfFrames;
    end
    
else
    frames = handles.Info(idx).frames;
end
if(~isfield(handles.Info(handles.curr_idx),'ref_frame') || isempty(handles.Info(handles.curr_idx).ref_frame))
    indices = randsample(frames-start_frame,min([100 frames-start_frame]))+(start_frame);
    indices(indices>frames) = [];
    V = mmread(vidname,indices); V = V(end);
    A = zeros(V.height,V.width,length(V.frames),'uint8');
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
else
    Bkg = handles.Info(idx).ref_frame;
end
handles.Info(idx).frames = frames;
delete(h);
h = figure; imshow(Bkg); pause(1); close(h);




% Enable controls on ROI selection
if(LeftMouse)
    set(handles.pushbutton10,'Enable','on');
    %     set(handles.pushbutton18,'Enable','off');
    if(info.LeftObjects)
        set(handles.pushbutton11,'Enable','on');
        set(handles.pushbutton12,'Enable','on');
        
    end
else
    set(handles.pushbutton10,'Enable','off');
    set(handles.pushbutton11,'Enable','off');
    set(handles.pushbutton12,'Enable','off');
    
    %     set(handles.pushbutton18,'Enable','off');
end
if(RightMouse)
    set(handles.pushbutton13,'Enable','on');
    %     set(handles.pushbutton19,'Enable','off');
    if(info.RightObjects)
        set(handles.pushbutton14,'Enable','on');
        set(handles.pushbutton15,'Enable','on');
        
    end
else
    set(handles.pushbutton13,'Enable','off');
    set(handles.pushbutton14,'Enable','off');
    set(handles.pushbutton15,'Enable','off');
    
    %     set(handles.pushbutton19,'Enable','off');
end


handles.Info(idx).start_idx = start_frame;
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
choice = questdlg('Draw free-hand or polygon?','Left half of the box ROI','Polygon','Free-hand','Cancel','Polygon');
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
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hfree = imfreehand(hax);
        BW = hfree.createMask;
        handles.Info(idx).ROIs.mask_left=BW;
        % Delete figure
        delete(hfig);
    case 'Polygon'
        
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.mask_left = BW;
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
choice = questdlg('Draw free-hand or automatically trace?','Glass object in left box','Auto','Free-hand','Ellipse','Auto');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
I = info.ref_frame;
switch choice
    case 'Auto'
        
%         I = rgb2gray(I);
        hy = fspecial('sobel');
        hx = hy';
        Iy = imfilter(double(I), hy, 'replicate');
        Ix = imfilter(double(I), hx, 'replicate');
        gradmag = sqrt(Ix.^2 + Iy.^2);
        
        BW = gradmag>25;
        [m n] = size(BW);
        if(m==480)
            
            BWclose = bwmorph(BW,'thicken',2);
            BWclose = imclose(BWclose,strel(ones(5)));
        else
            BWclose = bwmorph(BW,'thicken',4);
            BWclose = imclose(BWclose,strel(ones(5)));
        end
        
        
        % Now compute boundaries
        B = bwboundaries(BWclose,'noholes');
        % For each boundary, create an object
        
        Lobj = zeros(size(BW));
        
        for i=1:length(B)
            if(length(B{i})<800) % May need to adjust the value of 800 depending on size of the image
                Lobj = Lobj + imerode(poly2mask(B{i}(:,2),B{i}(:,1),m,n),strel('disk',2));
            end
        end
        Lobj = bwlabel(Lobj);
        % Now ask the user to identify glass object in left box
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hold on
        hfig = imgcf;
        hax = imgca;
        hpoint = impoint(hax);
        Coords= hpoint.getPosition;
        delete(hpoint);
        obj_idx = Lobj(floor(Coords(2)),floor(Coords(1)));
        if(obj_idx~=0)
            B = bwboundaries(Lobj==obj_idx);
            
            plot(B{1}(:,2),B{1}(:,1));
            handles.Info(idx).ROIs.BWobject1 = Lobj==obj_idx;
            pause(2);
        else
            try
                 mask=false(size(info.ref_frame,1),size(info.ref_frame,2));
            mask(Coords(2)-50:Coords(2)+50,Coords(1)-50:Coords(1)+50)=1;
            bw = activecontour(info.ref_frame,mask,'edge');
            bw = imfill(bw,'holes');
            B = bwboundaries(bw);
            plot(B{1}(:,2),B{1}(:,1));
            handles.Info(idx).ROIs.BWobject1 = bw;
            pause(2);
            end
           
        end
        % Delete figure
        delete(hfig);
        
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject1 = hobject1.createMask;
        pause(1)
        delete(hfig);
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject1 = hobject1.createMask;
        pause(1)
        delete(hfig);
    otherwise
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);
% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or automatically trace?','Metal object in left box','Auto','Free-hand','Ellipse','Auto');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
I = info.ref_frame;
switch choice
    case 'Auto'
%         I = rgb2gray(I);
        hy = fspecial('sobel');
        hx = hy';
        Iy = imfilter(double(I), hy, 'replicate');
        Ix = imfilter(double(I), hx, 'replicate');
        gradmag = sqrt(Ix.^2 + Iy.^2);
        
        BW = gradmag>25;
        [m n] = size(BW);
        if(m==480)
            
            BWclose = bwmorph(BW,'thicken',2);
            BWclose = imclose(BWclose,strel(ones(5)));
        else
            BWclose = bwmorph(BW,'thicken',4);
            BWclose = imclose(BWclose,strel(ones(5)));
        end
        
        
        % Now compute boundaries
        B = bwboundaries(BWclose,'noholes');
        % For each boundary, create an object
        
        Lobj = zeros(size(BW));
        
        for i=1:length(B)
            if(length(B{i})<800) % May need to adjust the value of 800 depending on size of the image
                Lobj = Lobj + imerode(poly2mask(B{i}(:,2),B{i}(:,1),m,n),strel('disk',2));
            end
        end
        Lobj = bwlabel(Lobj);
        % Now ask the user to identify glass object in left box
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hpoint = impoint(hax);
        Coords= hpoint.getPosition;
        obj_idx = Lobj(floor(Coords(2)),floor(Coords(1)));
        if(obj_idx~=0)
            B = bwboundaries(Lobj==obj_idx);
            hold on
            plot(B{1}(:,2),B{1}(:,1));
            handles.Info(idx).ROIs.BWobject2 = Lobj==obj_idx;
            pause(2);
        else
            try
                 mask=false(size(info.ref_frame,1),size(info.ref_frame,2));
            mask(Coords(2)-50:Coords(2)+50,Coords(1)-50:Coords(1)+50)=1;
            bw = activecontour(info.ref_frame,mask,'edge');
            bw = imfill(bw,'holes');
            B = bwboundaries(bw);
            plot(B{1}(:,2),B{1}(:,1));
            handles.Info(idx).ROIs.BWobject2 = bw;
            pause(2);
            end
           
        end
        % Delete figure
        delete(hfig);
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject2 = hobject1.createMask;
        pause(1)
        delete(hfig);
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject2 = hobject1.createMask;
        pause(1)
        delete(hfig);
    otherwise
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or polygon?','Right half of the box ROI','Polygon','Free-hand','Cancel','Polygon');
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
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hfree = imfreehand(hax);
        BW = hfree.createMask;
        handles.Info(idx).ROIs.mask_right = BW;
        % Delete figure
        delete(hfig);
    case 'Polygon'
        
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
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
choice = questdlg('Draw free-hand or automatically trace?','Glass object in right box','Auto','Free-hand','Ellipse','Auto');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
I = info.ref_frame;
switch choice
    case 'Auto'
%         I = rgb2gray(I);
        hy = fspecial('sobel');
        hx = hy';
        Iy = imfilter(double(I), hy, 'replicate');
        Ix = imfilter(double(I), hx, 'replicate');
        gradmag = sqrt(Ix.^2 + Iy.^2);
        
        BW = gradmag>25;
        [m n] = size(BW);
        if(m==480)
            
            BWclose = bwmorph(BW,'thicken',2);
            BWclose = imclose(BWclose,strel(ones(5)));
        else
            BWclose = bwmorph(BW,'thicken',4);
            BWclose = imclose(BWclose,strel(ones(5)));
        end
        
        
        % Now compute boundaries
        B = bwboundaries(BWclose,'noholes');
        % For each boundary, create an object
        
        Lobj = zeros(size(BW));
        
        for i=1:length(B)
            if(length(B{i})<800) % May need to adjust the value of 800 depending on size of the image
                Lobj = Lobj + imerode(poly2mask(B{i}(:,2),B{i}(:,1),m,n),strel('disk',2));
            end
        end
        Lobj = bwlabel(Lobj);
        % Now ask the user to identify glass object in left box
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hpoint = impoint(hax);
        Coords= hpoint.getPosition;
        obj_idx = Lobj(floor(Coords(2)),floor(Coords(1)));
        if(obj_idx~=0)
            B = bwboundaries(Lobj==obj_idx);
            hold on
            plot(B{1}(:,2),B{1}(:,1));
            handles.Info(idx).ROIs.BWobject3 = Lobj==obj_idx;
            pause(2);
        else
            try
                 mask=false(size(info.ref_frame,1),size(info.ref_frame,2));
            mask(Coords(2)-50:Coords(2)+50,Coords(1)-50:Coords(1)+50)=1;
            bw = activecontour(info.ref_frame,mask,'edge');
            bw = imfill(bw,'holes');
            B = bwboundaries(bw);
            plot(B{1}(:,2),B{1}(:,1));
            handles.Info(idx).ROIs.BWobject3 = bw;
            pause(2);
            end
           
        end
        % Delete figure
        delete(hfig);
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject3 = hobject1.createMask;
        pause(1)
        delete(hfig);
    case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject3 = hobject1.createMask;
        pause(1)
        delete(hfig);
    otherwise
        uicontrol(hObject);
        return;
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or automatically trace?','Metal object in right box','Auto','Free-hand','Ellipse','Auto');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
info = handles.Info(idx);
I = info.ref_frame;
switch choice
    case 'Auto'
%         I = rgb2gray(I);
        hy = fspecial('sobel');
        hx = hy';
        Iy = imfilter(double(I), hy, 'replicate');
        Ix = imfilter(double(I), hx, 'replicate');
        gradmag = sqrt(Ix.^2 + Iy.^2);
        
        BW = gradmag>25;
        [m n] = size(BW);
        if(m==480)
            
            BWclose = bwmorph(BW,'thicken',2);
            BWclose = imclose(BWclose,strel(ones(5)));
        else
            BWclose = bwmorph(BW,'thicken',4);
            BWclose = imclose(BWclose,strel(ones(5)));
        end
        
        
        % Now compute boundaries
        B = bwboundaries(BWclose,'noholes');
        % For each boundary, create an object
        
        Lobj = zeros(size(BW));
        
        for i=1:length(B)
            if(length(B{i})<800) % May need to adjust the value of 800 depending on size of the image
                Lobj = Lobj + imerode(poly2mask(B{i}(:,2),B{i}(:,1),m,n),strel('disk',2));
            end
        end
        Lobj = bwlabel(Lobj);
        % Now ask the user to identify glass object in left box
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hpoint = impoint(hax);
        Coords= hpoint.getPosition;
        obj_idx = Lobj(floor(Coords(2)),floor(Coords(1)));
        if(obj_idx~=0)
            B = bwboundaries(Lobj==obj_idx);
            hold on
            plot(B{1}(:,2),B{1}(:,1));
            handles.Info(idx).ROIs.BWobject4 = Lobj==obj_idx;
            pause(2);
        else
            try
                 mask=false(size(info.ref_frame,1),size(info.ref_frame,2));
            mask(Coords(2)-50:Coords(2)+50,Coords(1)-50:Coords(1)+50)=1;
            bw = activecontour(info.ref_frame,mask,'edge');
            bw = imfill(bw,'holes');
            B = bwboundaries(bw);
            plot(B{1}(:,2),B{1}(:,1));
            handles.Info(idx).ROIs.BWobject4 = bw;
            pause(2);
            end
           
        end
        % Delete figure
        delete(hfig);
    case 'Free-hand'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imfreehand(hax);
        handles.Info(idx).ROIs.BWobject4 = hobject1.createMask;
        pause(1)
        delete(hfig);
         case 'Ellipse'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hobject1 = imellipse(hax);
        wait(hobject1);
        handles.Info(idx).ROIs.BWobject3 = hobject1.createMask;
        pause(1)
        delete(hfig);
    otherwise
        uicontrol(hObject);
        return;
end
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
function pushbutton14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
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
        V = mmread(Info(i).filename,Info(i).ref_idx);
        Info(i).ref_frame = V(end).frames.cdata;
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




% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or polygon?','Left surface of the box ROI','Polygon','Free-hand','Cancel','Polygon');
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
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imfreehand(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_left = BW;
        delete(hfig);
    case 'Polygon'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = impoly(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_left = BW;
        delete(hfig);
end
guidata(hObject,handles);

% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = questdlg('Draw free-hand or polygon?','Right surface of the box ROI','Polygon','Free-hand','Cancel','Polygon');
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
        imshow(info.ref_frame,'Parent',hax_fig);
        hfig = imgcf;
        hax = imgca;
        hrect = imfreehand(hax);
        BW = hrect.createMask;
        handles.Info(idx).ROIs.surface_right = BW;
        delete(hfig);
    case 'Polygon'
        h=figure;
        hax_fig = gca;
        imshow(info.ref_frame,'Parent',hax_fig);
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
% Convert from min:sec to seconds
handles.Info(idx).duration_str = s;

handles.Info(idx).duration = str2num(s)*60;
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
% Convert from min:sec to seconds
handles.Info(idx).dimensions_L = str2double(s);
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



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
s=get(hObject,'String');
% Convert from min:sec to seconds
handles.Info(idx).dimensions_W = str2double(s);
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



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
s=get(hObject,'String');
% Convert from min:sec to seconds
handles.Info(idx).perimeter = str2double(s);
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


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = msgbox('Please wait while determining background. This may take several minutes');
set(hObject,'Enable','off');
set(hObject,'Selected','on');
files = get(handles.listbox3,'String');
folder = get(handles.text11,'String');

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
    indices = randsample(frames-start_idx,min([100 frames-start_idx]))+(start_idx);
    indices(indices>frames) = [];
    V = mmread(filename,indices); V = V(end);
    A = zeros(V.height,V.width,length(V.frames),'uint8');
    for k=1:length(V.frames)
        A(:,:,k) = rgb2gray(V.frames(k).cdata);
    end
    Bkg = uint8(mode(double(A),3));
    % Fix any 0's - this arises if the mouse sits in one location for most of
% the video and is incorporated as part of the background
    Bkg = double(Bkg);
    Bkg(Bkg==0) = nan;
    Bkg = uint8(inpaint_nans(Bkg,2));
    handles.Info(i).filename = filename;
    handles.Info(i).ref_frame = Bkg;
    handles.Info(i).frames = frames;
end
set(hObject,'Enable','on');
set(hObject,'Selected','off');
delete(h);
guidata(hObject,handles);


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
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


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
% Show the background 
h = figure;
hax = gca;
imshow(handles.Info(idx).ref_frame,'Parent',hax);


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
state = get(hObject,'Value');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(handles.curr_idx).Novel(1) = state;
guidata(hObject,handles);

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
state = get(hObject,'Value');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(handles.curr_idx).Novel(2) = state;
guidata(hObject,handles);

% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
state = get(hObject,'Value');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(handles.curr_idx).Novel(3) = state;
guidata(hObject,handles);

% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
state = get(hObject,'Value');
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
handles.Info(handles.curr_idx).Novel(4) = state;
guidata(hObject,handles);


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
SOR(handles.Info(handles.curr_idx),'DISPLAY',1);
