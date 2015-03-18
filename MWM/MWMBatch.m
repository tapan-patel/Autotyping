function analysis = MWMBatch(varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania
% Batch process files that have been initialized by MWMGUI -
% include the absolute folder name in Read_FNames.m
warning off
% if(~matlabpool('size'))
%     matlabpool open 
% end
if(isempty(which('mmread')))
    addpath('../mmread');
end
% fid_log = fopen(['MWM_' date '.log'],'w');
%%
if(nargin==0)
Info = [];
Folders = Read_FNames;
else
    Folders = varargin;
end
for j=1:size(Folders,1)
    %     if(~exist([Folders{j} '/MWM_results/MWManalysis.mat']));
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
        for i=1:length(idx)

                    analysis{i} = MWM(Info(idx(i)));

        end
        
%         analysis = analysis(1:length(idx));
        % Save
        % If MWM_results directory does not exist, create it
        if(~exist([Folders{j} '/MWM_results'],'dir'))
            mkdir([Folders{j} '/MWM_results']);
        end
        savefile = [Folders{j} '/MWM_results/MWManalysis.mat'];
        save(savefile,'analysis');
    else
        error([Folders{j} '/info.mat does not exist. Run MWMGUI first']);
    end
    
    % Output results to a txt file in /MWM_results directory
    fid = fopen([Folders{j} '/MWM_results/results.txt'],'w');
    fprintf(fid,'Filename \t Mouse Tag \t Latency (s) \t Path-length (m) \t Avg swim speed (m/s)\n' );
   
    for i=1:length(analysis)
        s = analysis{i};

            fprintf(fid,'%s \t %s \t %.2f \t %.2f \t %.2f',s.filename,s.Info.Tag,s.latency,s.pathlength,s.swimspeed);
            fprintf(fid,'\n');
    end
    fclose(fid);
end