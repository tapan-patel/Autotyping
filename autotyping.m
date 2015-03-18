function varargout = autotyping(varargin)
% AUTOTYPING MATLAB code for autotyping.fig
%      AUTOTYPING, by itself, creates a new AUTOTYPING or raises the existing
%      singleton*.
%
%      H = AUTOTYPING returns the handle to a new AUTOTYPING or the handle to
%      the existing singleton*.
%
%      AUTOTYPING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTOTYPING.M with the given input arguments.
%
%      AUTOTYPING('Property','Value',...) creates a new AUTOTYPING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before autotyping_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to autotyping_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help autotyping

% Last Modified by GUIDE v2.5 25-Aug-2014 14:41:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @autotyping_OpeningFcn, ...
    'gui_OutputFcn',  @autotyping_OutputFcn, ...
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


% --- Executes just before autotyping is made visible.
function autotyping_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to autotyping (see VARARGIN)

% Choose default command line output for autotyping
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes autotyping wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = autotyping_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String'));
choice = contents{get(hObject,'Value')};
switch choice
    case 'Barnes maze'
        delete(handles.figure1);
        cd('BarnesMaze');
        BMGUI;
        
    case 'Zero maze'
        delete(handles.figure1);
        cd('ZeroMaze');
        ZeroMazeGUI;
        
    case 'Y maze'
        delete(handles.figure1);
        cd('YMaze');
        YMazeGUI;
        
    case 'Open field'
        delete(handles.figure1);
        cd('OF');
        OFGUI;
        
    case 'SOR/NOR (2 objects)'
        delete(handles.figure1);
        cd('SOR');
        SORGUI;
        
    case 'SOR/NOR (3 objects)'
        delete(handles.figure1);
        cd('SOR3');
        SORGUI;
        
    case 'Social interaction'
        delete(handles.figure1);
        cd('Social');
        SocialGUI;
        
    case 'Fear conditioning'
        delete(handles.figure1);
        cd('FearConditioning');
        FCGUI;
        
    case 'Morris Water Maze'
        delete(handles.figure1);
        cd('MWM');
        MWMGUI;
end

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
