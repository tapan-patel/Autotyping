function varargout = INSPECT(varargin)
% INSPECT MATLAB code for INSPECT.fig
%      INSPECT, by itself, creates a new INSPECT or raises the existing
%      singleton*.
%
%      H = INSPECT returns the handle to a new INSPECT or the handle to
%      the existing singleton*.
%
%      INSPECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSPECT.M with the given input arguments.
%
%      INSPECT('Property','Value',...) creates a new INSPECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before INSPECT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to INSPECT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help INSPECT

% Last Modified by GUIDE v2.5 24-Aug-2014 15:10:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @INSPECT_OpeningFcn, ...
    'gui_OutputFcn',  @INSPECT_OutputFcn, ...
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


% --- Executes just before INSPECT is made visible.
function INSPECT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to INSPECT (see VARARGIN)

% Choose default command line output for INSPECT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes INSPECT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = INSPECT_OutputFcn(hObject, eventdata, handles)
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
idx = get(hObject,'Value');
handles.curr_idx = idx;
% Load the bouts for this selected file
[f1,f2] = fileparts(handles.analysis{idx}.Info.filename);
try
    h = msgbox(['Loading interaction bouts for ' f2]);
    load([f1 '/Social_Bouts/' f2 '.mat']);
    delete(h);
catch
    errordlg(['Could not load ' f1 '/Social_Bouts/' f2 '.mat'],'Bad Input','modal')
    uicontrol(hObject)
    return;
end
handles.s = s;
set(handles.uitable1,'Data',cell(1,3));
set(handles.popupmenu1,'Value',1);
set(handles.text3,'String','- (s)');
set(handles.text4,'String','- (s)');
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[info_name, dirpath] = uigetfile('*.mat','Select SI_analysis.mat file');

try
    load([dirpath info_name]);
catch
    
    errordlg('Make an appropriate selection of SI_analysis.mat file','Bad Input','modal')
    uicontrol(hObject)
    return;
end

if(~iscell(analysis))
    analysis = {analysis};
end
% Now populate listbox1
handles.folder_name = dirpath;
for i=1:numel(analysis)
    if(~isempty(analysis{i}))
    [~,x,ext] = fileparts(analysis{i}.Info.filename);
    filename{i} = [x ext];
    end
end
set(handles.listbox1,'String',filename,...
    'Value',1)
handles.analysis = analysis;
guidata(hObject,handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
val = get(hObject,'Value');
s = handles.s;
if(val==2)
    % TOp Left, 0-10
    if(isfield(s,'TopLeft1_Bouts'))
        handles.Bouts = s.TopLeft1_Bouts;
        handles.L = s.TopLeft1_L;
    end
    
end
if(val==3)
    % Glass Left
    if(isfield(s,'TopRight1_Bouts'))
        handles.Bouts = s.TopRight1_Bouts;
        handles.L = s.TopRight1_L;
    end
end
if(val==4)
    % Glass Left
    if(isfield(s,'TopLeft2_Bouts'))
        handles.Bouts = s.TopLeft2_Bouts;
        handles.L = s.TopLeft2_L;
    end
end
if(val==5)
    % Glass Left
    if(isfield(s,'TopRight2_Bouts'))
        handles.Bouts = s.TopRight2_Bouts;
        handles.L = s.TopRight2_L;
    end
end
if(val==6)
    % Glass Left
    if(isfield(s,'BottomLeft1_Bouts'))
        handles.Bouts = s.BottomLeft1_Bouts;
        handles.L = s.BottomLeft1_L;
    end
    
end
if(val==7)
    % Glass Left
    if(isfield(s,'BottomRight1_Bouts'))
        handles.Bouts = s.BottomRight1_Bouts;
        handles.L = s.BottomRight1_L;
    end
end
if(val==8)
    % Glass Left
    if(isfield(s,'BottomLeft2_Bouts'))
        handles.Bouts = s.BottomLeft2_Bouts;
        handles.L = s.BottomLeft2_L;
    end
    
end
if(val==9)
    % Glass Left
    if(isfield(s,'BottomRight2_Bouts'))
        handles.Bouts = s.BottomRight2_Bouts;
        handles.L = s.BottomRight2_L;
    end
end

fps = s.fps;
A = regionprops(handles.L,'Area');
Data = cell(1,3);
for k=1:max(handles.L)
    Data(k,1) = {k};
    Data(k,2) = {A(k).Area/fps};
    Data(k,3) = Data(k,2);
end
set(handles.text3,'String',num2str(nnz(handles.L)/fps));
set(handles.text4,'String',num2str(nnz(handles.L)/fps));
set(handles.uitable1,'Data',Data);
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
% pause;
Data = get(handles.uitable1,'Data');
try
    row = eventdata.Indices(1);
    col = eventdata.Indices(2);
    row = Data{row,1};
    if(col==1 || col==2)
%         h = figure;
%         hax = gca;
        idx = find(handles.L==row);
        implay(handles.Bouts.frames(idx));
%         for k=1:length(idx)
%             imshow(handles.Bouts.frames(idx(k)).cdata,'Parent',hax);
%             pause(1/(handles.s.fps+2))
%         end
%         close(h);
    end
    if(col==3)
        % User manually wants to correct the interaction bout time
        total_time = sum([Data{:,4}]);
        set(handles.text4,'String',[num2str(total_time) ' (s)']);
    end
    set(handles.uitable1,'Data',Data);
    guidata(hObject,handles);
end


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
Data = get(handles.uitable1,'Data');
try
    row = eventdata.Indices(1);
    col = eventdata.Indices(2);
    row = Data{row,1};
    if(col==3)
        % User manually wants to correct the interaction bout time
        total_time = sum([Data{:,3}]);
        set(handles.text4,'String',[num2str(total_time) ' (s)']);
    end
    set(handles.uitable1,'Data',Data);
    guidata(hObject,handles);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isfield(handles,'Bouts') || isempty(handles.Bouts))
    errordlg('Please make a video and object selection first.');
    uicontrol(hObject);
end

% h = figure;
% hax = gca;
% fps = handles.s.fps;
% for i=1:length(handles.Bouts.frames)
%     imshow(handles.Bouts.frames(i).cdata,'Parent',hax);
%     title(['Epoch # ' num2str(handles.L(i))]);
%     pause(1/(fps+2));
% end
% close(h)
implay(handles.Bouts.frames);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    % Sort the entries in datatable by time duration, descending order
    Data = get(handles.uitable1,'Data');
    automated_t = [Data{:,2}];
    [~,idx] = sort(automated_t,'descend');
    % If data are already sorted descending, show ascending order
    if(nnz(idx==1:length(idx))==length(idx))
         [~,idx] = sort(automated_t,'ascend');
    end
    sorted_data = Data(idx,:);
    set(handles.uitable1,'Data',sorted_data);
end
