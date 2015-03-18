function analysis = freezetime(Info)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania
% Read in a movie file
abs_mv_path = Info.filename;
[~,vidname] = fileparts(Info.filename);
hbar = waitbar(0,sprintf('Processing %s\n0%%', vidname));
set(findall(hbar,'type','text'),'Interpreter','none');
if(isempty(which('mmread')))
    addpath('../mmread');
end

% disp(['Processing ' abs_mv_path]);

frames = mmcount(abs_mv_path);

times = zeros(frames,1);
%% Process f frames at a time
thresh_mat = Inf*ones(frames,'single');

f = 150;
start_idx = Info.start_idx;
T = [start_idx+1:f:frames frames];
[~,vidname] = fileparts(abs_mv_path);
disp(vidname);
fname = tempname(pwd);
parfor_progress(length(T),fname,vidname);
for k =1:length(T)-1
   
        V = mmread(abs_mv_path,T(k):T(k+1)-1); V = V(end);
   
    n = length(V.frames);
    waitbar(T(k)/frames,hbar,sprintf('Processing %s\n%d %%',vidname,round(100*T(k)/frames)));
    set(findall(hbar,'type','text'),'Interpreter','none');
    
    % Convert to gray scale & resize
    for j=1:n
        I = rgb2gray(V.frames(j).cdata);
        V.frames(j).cdata = I;
    end
    for j=1:n
        i = T(k)+j-1;
        times(i) = V(end).times(j);
        
        if(mod(i-start_idx,1000)==0)
            disp(['     ' abs_mv_path ': ' num2str(i-start_idx) ' of ' num2str(frames-start_idx) ' frames processed.']);
        end
        % Compute the graythresh of image difference of each pair of
        % frames
        for m=j+1:n
            p = T(k)+m-1;
                        I1 = V.frames(j).cdata;
                        I2 = V.frames(m).cdata;
                        D = imabsdiff(I1,I2);
% %                         t = 255*graythresh(D);
%                         thresh_mat(i,p) = floor(t);
%                         thresh_mat(p,i) = floor(t);
                        thresh_mat(i,p) = floor(sum(sum(D)));
                        thresh_mat(p,i) = thresh_mat(i,p);
%                         
%                         
%             I1 = V.frames(j).cdata; 
%             I2 = V.frames(m).cdata;
%             D = imabsdiff(I1,I2);
%             thresh_mat(i,p) = mean(mean(D))*255;
%             thresh_mat(p,i) = thresh_mat(i,p);
        end
    end
    parfor_progress(-1,fname,vidname);
end
thresh_mat = thresh_mat(1:frames,1:frames);
%% Determine frame rate
start_idx = start_idx+1;
fitresult = createFit1(start_idx:frames,times(start_idx:frames)');
fps = 1/fitresult.p1;
analysis.fps = fps;
if(isfield(Info,'thresh') && ~isempty(Info.thresh))
thr = Info.thresh;
else
    [r,c] = size(D);
    thr = r*c*1.5;
end
BW = thresh_mat<thr;


M = BW;
FL = zeros(size(M,1),1);
bout = 0;
bout_num = 1;
bout_length = floor(fps);
for i=1:size(M,1)-fps-1
    if(nnz(M(i,i+1:i+fps+1))>=bout_length)
        if(bout==0)
            bout = 1;
            FL(i+1:i+fps+1) = bout_num;
            bout_num = bout_num +1;
        else
            FL(i+1:i+fps+1) = bout_num;
        end
    else
        bout = 0;
    end
end


freezing_L = FL;
%%
start_time = times(start_idx);
if(isfield(Info,'duration') && ~isempty(Info.duration))
    duration = Info.duration;
else
    duration = 5*60;
end
end_time = start_time + duration;
analysis.duration = duration;
% Find the index of end time
end_idx = min([find(abs(times-end_time)<.1,1,'first') frames]);
freezing_L(end_idx:end) = 0;

analysis.freezing_L = freezing_L;
analysis.TotalFreezeTime = nnz(freezing_L)/fps;
analysis.FractionalFreeze = analysis.TotalFreezeTime/analysis.duration;
analysis.Info = Info;
%% Freezing time per 1 minute interval

idx = floor(linspace(start_idx,frames,duration/(60)+1));

for i=1:length(idx)-1
    analysis.Intervals(1,i) = (nnz(freezing_L(idx(i):idx(i+1))==1)./fps)/60;
end
%% Save .mat for this file
[folder_name, vidname] = fileparts(abs_mv_path);
if(~exist([folder_name '/FC_results'],'dir'))
    mkdir([folder_name '/FC_results']);
end
analysis.filename = abs_mv_path;
analysis.thresh_mat = thresh_mat;
save([folder_name '/FC_results/' vidname '.mat'],'analysis');

% disp(['Finished processing ' abs_mv_path]);
parfor_progress(0,fname,vidname);
try
delete(hbar);
end