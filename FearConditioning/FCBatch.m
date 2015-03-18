function analysis = FCBatch(varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania

% Batch process files that have been initialized by OFGUI -
% include the absolute folder name in Read_FNames.m
warning off
% if(~matlabpool('size'))
%     matlabpool open 
% end
if(isempty(which('mmread')))
    addpath('../mmread');
end
% fid_log = fopen(['SOR_' date '.log'],'w');
%%
if(nargin==0)
Info = [];
Folders = Read_FNames;
else
    Folders = varargin;
end
for j=1:size(Folders,1)
    %     if(~exist([Folders{j} '/SOR_results/SORanalysis.mat']));
    if(exist([Folders{j,1} '/info.mat']))
        load([Folders{j,1} '/info.mat']);
        N = numel(Info);
        % Remove duplicates
        files = cell(N,1);
        for i=1:N
            [~,files{i}] = fileparts(Info(i).filename);
        end
        [~,idx] = unique(files);
        analysis = cell(length(idx),1);
        % Load empty_chamber info
        load([Folders{j,1} '/info_empty_chamber.mat']);
        if(isfield(info_empty,'filename'))
            disp(['Determining the camera noise using empty chamber video: ' info_empty.filename]);
            thr = GetThreshold(info_empty);
        else
            V = mmread(Info(idx(1)).filename,1);
            D = rgb2gray(V(end).frames.cdata);
            [r,c] = size(D);
            thr = r*c*info_empty.thr;
        end
        for i=1:length(idx)
%                 fprintf(fid_log,'Processing %s\n', Info(idx(i)).filename);
                [folder,vidname] = fileparts(Info(idx(i)).filename);
                if(exist([folder '/FC_results/' vidname '.mat'],'file'))
                    s = load([folder '/FC_results/' vidname '.mat']);
                    analysis{i} = s.analysis;
                else
                    Info(idx(i)).thresh = thr;
                    analysis{i} = freezetime(Info(idx(i)));
                end
        end
        
%         analysis = analysis(1:length(idx));
        % Save
        % If SOR_results directory does not exist, create it
        if(~exist([Folders{j} '/FC_results'],'dir'))
            mkdir([Folders{j} '/FC_results']);
        end
        savefile = [Folders{j} '/FC_results/FCanalysis.mat'];
        save(savefile,'analysis');
    else
        error([Folders{j} '/info.mat does not exist. Run FCGUI first']);
    end
    intervals = Info(1).duration/(60);
    % Output results to a txt file in /SOR_results directory
    fid = fopen([Folders{j} '/FC_results/results.txt'],'w');
    fprintf(fid,'Filename \t Mouse Tag \t Total freeze time \t Fractional freeze (FF) time ');
    for i=1:intervals
        fprintf(fid,'\tFF interval %i',i);
    end
    fprintf(fid,'\n');
    for i=1:length(analysis)
        s = analysis{i};
%         try
%         Ambulation = sum(s.PathLength);
          
            fprintf(fid,'%s \t %s \t %.2f \t %.2f',s.filename,s.Info.Tag,s.TotalFreezeTime,s.FractionalFreeze);
           
            for k=1:length(s.Intervals)
                fprintf(fid,'\t%.2f',s.Intervals(k));
            end
            
            fprintf(fid,'\n');
            
        
    end
    fclose(fid);
    
end
CompileFreeze(analysis);