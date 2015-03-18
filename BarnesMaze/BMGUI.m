function varargout = BMGUI(varargin)
% BMGUI MATLAB code for BMGUI.fig
%      BMGUI, by itself, creates a new BMGUI or raises the existing
%      singleton*.
%
%      H = BMGUI returns the handle to a new BMGUI or the handle to
%      the existing singleton*.
%
%      BMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BMGUI.M with the given input arguments.
%
%      BMGUI('Property','Value',...) creates a new BMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BMGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BMGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BMGUI

% Last Modified by GUIDE v2.5 06-Mar-2015 18:19:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BMGUI_OpeningFcn, ...
    'gui_OutputFcn',  @BMGUI_OutputFcn, ...
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


% --- Executes just before BMGUI is made visible.
function BMGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BMGUI (see VARARGIN)

% Choose default command line output for BMGUI
handles.output = hObject;
if(isempty(which('mmread')))
    addpath('../mmread');
end
if(isempty(which('inpaint_nans')))
    addpath('../Inpaint_nans');
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BMGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BMGUI_OutputFcn(hObject, eventdata, handles)
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
folder_name = uigetdir('','Select a folder containing Barnes Maze videos');
if(~isstr(folder_name))
    folder_name = handles.parent_dir;
end
handles.folder_name = folder_name;

guidata(hObject,handles);

handles = load_listbox(folder_name,handles);
guidata(hObject,handles);
function handles = load_listbox(dir_path,handles)
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
set(handles.text3,'String',dir_path)
for i=1:length(handles.file_names)
    handles.Info(i).filename = fullfile(dir_path,handles.file_names{i});
end
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
if(strcmp(selection,'open'))
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
try
    set(handles.edit1,'String',handles.Info(idx).MouseTag);
catch
    set(handles.edit1,'String',[]);
end
try
    set(handles.edit2,'String',handles.Info(idx).start_time_str);
catch
    set(handles.edit2,'String',[]);
end
try
    set(handles.edit3,'String',handles.Info(idx).end_time_str);
catch
    set(handles.edit3,'String',[]);
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
tag = get(hObject,'String');
handles.Info(idx).MouseTag = tag;
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
[minute,sec] = strtok(s,':');
if(isempty(sec))
    errordlg('You must enter time as min:sec (e.g. 0:34 or 2:56)','Bad Input','modal')
    
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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
if(~isempty(handles.Info(idx).MouseTag) && ~isempty(handles.Info(idx).start_time))
    try
        if(~isempty(handles.Info(idx).filename))
            abs_mv_path = handles.Info(idx).filename;
        else
            abs_mv_path = fullfile(handles.folder_name, handles.curr_file);
            handles.Info(idx).filename = abs_mv_path;
        end
    catch
        abs_mv_path = fullfile(handles.folder_name, handles.curr_file);
        handles.Info(idx).filename = abs_mv_path;
    end
    h = msgbox('Please wait while determining background. This may take a minute');
    frames = mmcount(abs_mv_path);
    start_frame = TimeToFrame(abs_mv_path,1,frames,handles.Info(idx).start_time);
    
    handles.Info(idx).start_idx = start_frame;
    indices = randsample(frames-start_frame,min([100 frames-start_frame]))+(start_frame);
    indices(indices>frames) = [];
    indices = sort(indices);
    V = mmread(abs_mv_path,indices); V = V(end);
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
    
    % To automatically identify the escape holes
    BW = bwfill(edge(Bkg,'canny'),'holes');
    L = bwlabel(BW);
    C = regionprops(L,'Area');
    [~,d] = max([C.Area]);
    L = L==d;
    imgrad = edge(Bkg,'canny');
    A = imgrad.*L;
    
    L = imerode(L,strel('disk',4));
    BW = L.*imgrad;
    BW = bwfill(BW,'holes');
    L = bwlabel(BW);
    if(max(max(L))<20)
        L = bwlabel(bwfill(edge(Bkg,'canny'),'holes'));
        BW = logical(L);
        correction = 1;
    else
        correction = 0;
    end
    C = regionprops(BW,'Area','MajorAxisLength','MinorAxisLength');
    A = [C.Area];
    for i=1:length(A)
        if(A(i)<400 || C(i).MinorAxisLength/C(i).MajorAxisLength<.7)
            L(L==i) = 0;
        end
    end
    L = bwlabel(L);
    if(max(L(:))>20)
        L(L==1)=0;
    end
    L = bwlabel(L);
    % L = CWLabel(handles.Info(idx).Maze,L,20,handles.Info(idx).escape_box);
    handles.Info(idx).L = L;
    handles.Info(idx).Bkg = Bkg;
    B = bwboundaries(L);
    figure; imshow(Bkg); axis image;
    hold on
    for i=1:length(B)
        boundary = B{i};
        plot(boundary(:,2), boundary(:,1),'b','LineWidth',4);
    end
    % figure; subplot(2,1,1); imshow(Bkg); axis image;
    %  title(handles.Info(idx).filename,'Interpreter','none');
    %  freezeColors; subplot(2,1,2); imagesc(L); axis image; colormap jet; colorbar;
    % set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
    % hold on
    % centroid = regionprops(L,'Centroid');
    % for i=1:length(centroid)
    %     plot(text(centroid(i).Centroid(1)+20,centroid(i).Centroid(2)+10,num2str(i),'Color','w'))
    % end
    delete(h);
end
guidata(hObject,handles);
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
h = figure;
hax = gca;
imshow(handles.Info(idx).Bkg,'Parent',hax);
B1 = bwboundaries(handles.Info(idx).L);
hold on
for i=1:length(B1)
    plot(B1{i}(:,2),B1{i}(:,1),'b','LineWidth',3);
end
pt = impoint;
coord = pt.getPosition;
ROI = handles.Info(idx).L(floor(coord(2)),floor(coord(1)));
B1 = bwboundaries(handles.Info(idx).L==ROI);
hold on
plot(B1{1}(:,2),B1{1}(:,1),'r','LineWidth',4);
handles.Info(idx).escape_box = ROI;
pause(0.05);
delete(h);
guidata(hObject,handles);
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Info_tmp = handles.Info;
% Go through and only keep elements that have a filename field
cntr = 1;
for i=1:numel(Info_tmp)
    if(~isempty(Info_tmp(i).filename) && ~isempty(Info_tmp(i).MouseTag))
        filename = Info_tmp(i).filename;
        if(~isfield(Info_tmp(i),'escape_box') || isempty(Info_tmp(i).escape_box))
            errordlg(['Escape box for ' filename ' not defined! Please try again before saving.','Undefined escape box'])
            return;
        elseif(~isfield(Info_tmp(i),'Maze') || isempty(Info_tmp(i).Maze))
            errordlg(['Maze outline for ' filename ' not defined! Please try again before saving.','Undefined Maze'])
            return;
        else
            if(isfield(handles.Info(i),'renumbered') && ~isempty(handles.Info(i).renumbered) && handles.Info(i).renumbered)
                L = handles.Info(i).L;
                % Skip automated renumbering because the user manually renumbered the ROIs
            else
                
                L = CWLabel(Info_tmp(i).Maze,Info_tmp(i).L,Info_tmp(i).escape_box);
            end
            Info_tmp(i).L = L;
            Info(cntr) = Info_tmp(i);
            cntr = cntr+1;
        end
    end
end
savefile = [handles.folder_name '/info.mat'];
if(exist(savefile))
    choice = questdlg([savefile ' already exists. Overwrite?']);
    switch choice
        case 'Yes'
            save(savefile,'Info');
            disp(['Barnes Maze Initializations saved to ' savefile]);
            
        case 'No'
            uicontrol(hObject);
            return
        case 'Cancel'
            uicontrol(hObject);
            return
    end
else
    save(savefile,'Info');
    disp(['Barnes Maze Initializations saved to ' savefile]);
end

button = questdlg('Do you want to batch process these files now or later?','Process now?','Now','Later','Later');
switch button
    case 'Now'
        h = msgbox('Submitting all files for batch processing. ');
         pause(2);
        try
            delete(h);
        end
        BarnesBatch(handles.folder_name);
        
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Go through each video file and get the background ref frame for each
h = msgbox('Please wait while determining background. This may take several minutes');
for i=1:length(handles.Info)
    try
        delete(hfig);
    end
    if(~isempty(handles.Info(i).MouseTag) && ~isempty(handles.Info(i).start_time))
        idx = i;
        try
            if(~isempty(handles.Info(idx).filename))
                abs_mv_path = handles.Info(idx).filename;
            else
                abs_mv_path = fullfile(handles.folder_name, handles.curr_file);
                handles.Info(idx).filename = abs_mv_path;
            end
        catch
            abs_mv_path = fullfile(handles.folder_name, handles.curr_file);
            handles.Info(idx).filename = abs_mv_path;
        end
        frames = mmcount(abs_mv_path);
        start_frame = TimeToFrame(abs_mv_path,1,frames,handles.Info(idx).start_time);
        handles.Info(idx).start_idx = start_frame;
        f_idx = randsample(frames-start_frame,100)+start_frame;
        f_idx(f_idx>frames) = [];
        f_idx = sort(f_idx);
        V = mmread(abs_mv_path,f_idx); V = V(end);
        A = zeros(V.height,V.width,length(V.frames),'uint8');
        for k=1:length(V.frames)
            A(:,:,k) = rgb2gray(V.frames(k).cdata);
        end
        Bkg = uint8(mode(double(A),3));
        Bkg = double(Bkg);
        Bkg(Bkg==0) = nan;
        Bkg = uint8(inpaint_nans(Bkg,2));
        % To automatically identify the escape holes
        BW = bwfill(edge(Bkg,'canny'),'holes');
        L = bwlabel(BW);
        C = regionprops(L,'Area');
        [~,d] = max([C.Area]);
        L = L==d;
        imgrad = edge(Bkg,'canny');
        A = imgrad.*L;
        L = imerode(L,strel('disk',4));
        BW = L.*imgrad;
        BW = bwfill(BW,'holes');
        L = bwlabel(BW);
        C = regionprops(BW,'Area','MajorAxisLength','MinorAxisLength');
        A = [C.Area];
        for i=1:length(A)
            if(A(i)<400 || C(i).MinorAxisLength/C(i).MajorAxisLength<.7)
                L(L==i) = 0;
            end
        end
        L = bwlabel(L);
        
        handles.Info(idx).L = L;
        handles.Info(idx).Bkg = Bkg;
        
        B = bwboundaries(L);
        hfig=figure; imshow(Bkg); axis image;
        hold on
        for i=1:length(B)
            boundary = B{i};
            plot(boundary(:,2), boundary(:,1),'b','LineWidth',4);
        end
        
    end
end
delete(h);
guidata(hObject,handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end

if(~isempty(handles.Info(idx).MouseTag) && isfield(handles.Info(idx),'escape_box') && isfield(handles.Info(idx),'Maze') ...
        && ~isempty(handles.Info(idx).escape_box))
    
    L = handles.Info(idx).L;
    Bkg = handles.Info(idx).Bkg;
    if(isfield(handles.Info(idx),'renumbered') && ~isempty(handles.Info(idx).renumbered) && handles.Info(idx).renumbered)
        L = handles.Info(idx).L; % Skip automated renumbering because the user manually renumbered the ROIs
    else
        L = CWLabel(handles.Info(idx).Maze,L,handles.Info(idx).escape_box);
        handles.Info(idx).L = L;
    end
    % Show background image, show ROI boundaries and label the ROIs
    B = bwboundaries(L);
    figure; imshow(Bkg); axis image; hold on;
    for k=1:length(B)
        boundary = B{k};
        plot(boundary(:,2),boundary(:,1),'b','LineWidth',4);
    end
    B = bwboundaries(handles.Info(idx).Maze);
    for k=1:length(B)
        boundary = B{k};
        plot(boundary(:,2),boundary(:,1),'w','LineWidth',4);
    end
    C = regionprops(L,'Centroid');
    for i=1:20
        if(i==20)
            plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,'Target','Color','r','FontSize',18,'Rotation',45));
        end
        if(i==19)
            plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,'Opposite','Color','r','FontSize',18,'Rotation',-45));
        end
        if(i<10)
            plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,num2str(i),'Color','r','FontSize',18));
        end
        if(i>=10 && i~=20 && i~=19)
            plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,num2str(i-19),'Color','r','FontSize',18));
        end
    end
    %         figure; subplot(2,1,1); imshow(Bkg); axis image;
    %         title(handles.Info(idx).filename,'Interpreter','none');
    %         freezeColors; subplot(2,1,2); imagesc(L); axis image; colormap jet; colorbar;
    %         set(gca,'XTickLabel',[]); set(gca,'YTickLabel',[]);
    %         hold on
    %         centroid = regionprops(L,'Centroid');
    %         for i=1:length(centroid)
    %             plot(text(centroid(i).Centroid(1)+20,centroid(i).Centroid(2)+10,num2str(i),'Color','w'))
    %         end
    
else
    
    errordlg('Either background, maze or escape box not set. Please try again.','Error!');
    return;
end
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
endif(~isempty(handles.Info(idx).MouseTag))
    try
        if(~isempty(handles.Info(idx).filename))
            abs_mv_path = handles.Info(idx).filename;
        else
            abs_mv_path = fullfile(handles.folder_name, handles.curr_file);
            handles.Info(idx).filename = abs_mv_path;
        end
    catch
        abs_mv_path = fullfile(handles.folder_name, handles.curr_file);
        handles.Info(idx).filename = abs_mv_path;
    end
    if(isfield(handles.Info(idx),'Bkg') && ~isempty(handles.Info(idx).Bkg))
        Bkg = handles.Info(idx).Bkg;
        L = handles.Info(idx).L;
    else
        h = msgbox('Please wait while determining background. This may take a minute');
        frames = mmcount(abs_mv_path);
        start_frame = TimeToFrame(abs_mv_path,1,1000,handles.Info(idx).start_time);
        handles.Info(idx).start_idx = start_frame;
        indices = randsample(frames-start_frame,min([100 frames-start_frame]))+(start_frame);
        indices(indices>frames) = [];
        indices = sort(indices);
        V = mmread(abs_mv_path,indices); V = V(end);
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
        delete(h);
        BW = bwfill(edge(Bkg,'canny'),'holes');
        L = bwlabel(BW);
        C = regionprops(L,'Area');
        [~,d] = max([C.Area]);
        L = L==d;
        imgrad = edge(Bkg,'canny');
        A = imgrad.*L;
        
        L = imerode(L,strel('disk',4));
        BW = L.*imgrad;
        BW = bwfill(BW,'holes');
        L = bwlabel(BW);
        if(max(max(L))<20)
            L = bwlabel(bwfill(edge(Bkg,'canny'),'holes'));
            BW = logical(L);
            correction = 1;
        else
            correction = 0;
        end
        C = regionprops(BW,'Area','MajorAxisLength','MinorAxisLength');
        A = [C.Area];
        for i=1:length(A)
            if(A(i)<400 || C(i).MinorAxisLength/C(i).MajorAxisLength<.7)
                L(L==i) = 0;
            end
        end
        L = bwlabel(L);
        if(max(L(:))>20)
            L(L==1)=0;
        end
        L = bwlabel(L);
    end
    
    L = SegmentROIs(Bkg,L);
    
    handles.Info(idx).L = L;
    handles.Info(idx).Bkg = Bkg;
    
    B = bwboundaries(L);
    figure; imshow(Bkg); axis image;
    hold on
    for i=1:length(B)
        boundary = B{i};
        plot(boundary(:,2), boundary(:,1),'b','LineWidth',4);
    end
    handles.Info(idx).L = L;
    handles.Info(idx).Bkg = Bkg;
    
end
guidata(hObject,handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
idx = handles.curr_idx;
catch
    errordlg('You must first select a video from the listbox.','Bad input','modal');
    return;
end
if(~isempty(handles.Info(idx).filename))
    abs_mv_path = handles.Info(idx).filename;
else
    abs_mv_path = fullfile(handles.folder_name, handles.curr_file);
    handles.Info(idx).filename = abs_mv_path;
end
V = mmread(abs_mv_path,600);
h = figure;
imshow(V.frames.cdata);
h1 = imellipse;
wait(h1);
handles.Info(idx).Maze = h1.createMask;
close(h);
guidata(hObject,handles);



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
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


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[info_name, dirpath] = uigetfile('*.mat','Select a info.mat file');

try
    load([dirpath info_name]);
catch
    
    errordlg('Make an appropriate selection of info.mat file','Bad Input','modal')
    
    return;
end
% Now populate listbox1
handles.folder_name = dirpath;
filename = cell(1);
for i=1:numel(Info)
    [~,x,ext] = fileparts(Info(i).filename);
    filename{i} = [x ext];
end
parent_dir = pwd;
cd(handles.folder_name);
fnames = dir('*.wmv');
fnames = [fnames;dir('*.avi')];
fnames = [fnames;dir('*.mpg')];
fnames = [fnames;dir('*.mpeg')];
fnames = [fnames;dir('*.mp4')];
fnames = [fnames;dir('*.mov')];
fnames = [fnames;dir('*.MPG')];
cd(parent_dir);
for i=1:numel(fnames)
    if(~strcmp(fnames(i).name,filename))
        filename{end+1} = fnames(i).name;
    end
end
set(handles.listbox1,'String',filename,...
    'Value',1)
set(handles.text3,'String',handles.folder_name)
handles.Info = Info;
guidata(hObject,handles);


% --- Executes on button press in pushbutton10.
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
BarnesMaze(handles.Info(handles.curr_idx),'DISPLAY',1);


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    idx = handles.curr_idx;
catch
    errordlg('You must make a video selection from the listbox first');
    return;
end
msg = sprintf('You will be prompted to click on an ROI in the subsequent images.');
msg = sprintf('%s\nThe target hole is the escape box and "opposite" is the hole opposite to the escape box.\n',msg);
msg = sprintf('%sHoles 1 to 9 are counterclockwise from target to opposite; holes -1 to -9 are clockwise from target to opposite',msg);
hmsg = msgbox(msg);
uiwait(hmsg);
L = handles.Info(idx).L;
L1 = zeros(size(L));
% Escape box
h = figure;
hax = gca;
imshow(handles.Info(idx).Bkg,'Parent',hax);
title('Select the escape box');
[x,y] = ginput(1);
ROI = L(floor(y),floor(x));
L1(L==ROI) = 20;
close(h);

% Opposite box
h = figure;
hax = gca;
imshow(handles.Info(idx).Bkg,'Parent',hax);
title('Select the hole opposite to the escape box');
B = bwboundaries(L1==20);
hold on
plot(B{1}(:,2),B{1}(:,1),'r');
C = regionprops(L1==20);
text(hax,C.Centroid(2),C.Centroid(1),'Target');
[x,y] = ginput(1);
ROI = L(floor(y),floor(x));
L1(L==ROI) = 19;
close(h);

% Select holes 1 - 9
for i=1:9
    h = figure;
    hax = gca;
    imshow(handles.Info(idx).Bkg,'Parent',hax);
    title(sprintf('Select hole # %d',i));
    B = bwboundaries(L1);
    hold on
    for j=1:length(B)
        plot(B{j}(:,2),B{j}(:,1),'r');
    end
    
    [x,y] = ginput(1);
    ROI = L(floor(y),floor(x));
    L1(L==ROI) = i;
    close(h);
end

% Holes -1 to -9
for i=1:9
    h = figure;
    hax = gca;
    imshow(handles.Info(idx).Bkg,'Parent',hax);
    title(sprintf('Select hole # %d',-1*i));
    B = bwboundaries(L1);
    hold on
    for j=1:length(B)
        plot(B{j}(:,2),B{j}(:,1),'r');
    end
    
    [x,y] = ginput(1);
    ROI = L(floor(y),floor(x));
    L1(L==ROI) = 19-i; % Hole -1 is labeled 18, hole -2 is labeled 17, etc
    close(h);
end

handles.Info(idx).L = L1;
L = L1;
Bkg = handles.Info(idx).Bkg;
handles.Info(idx).renumbered = 1;
guidata(hObject,handles);
B = bwboundaries(L);
figure; imshow(Bkg); axis image; hold on; title('Renumbered ROIs. You may exit this window when satisfied');
for k=1:length(B)
    boundary = B{k};
    plot(boundary(:,2),boundary(:,1),'b','LineWidth',4);
end
B = bwboundaries(handles.Info(idx).Maze);
for k=1:length(B)
    boundary = B{k};
    plot(boundary(:,2),boundary(:,1),'w','LineWidth',4);
end
C = regionprops(L,'Centroid');
for i=1:20
    if(i==20)
        plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,'Target','Color','r','FontSize',18,'Rotation',45));
    end
    if(i==19)
        plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,'Opposite','Color','r','FontSize',18,'Rotation',-45));
    end
    if(i<10)
        plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,num2str(i),'Color','r','FontSize',18));
    end
    if(i>=10 && i~=20 && i~=19)
        plot(text(C(i).Centroid(1)+20,C(i).Centroid(2)+10,num2str(i-19),'Color','r','FontSize',18));
    end
end
