function ZeroMazeBatch(varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania
% if(~matlabpool('size'))
%     matlabpool open
% end
pause(1e-6);
if(isempty(which('mmread')))
    addpath('../mmread');
end
if(nargin==0)
    Info = [];
    Folders = Read_FNames;
else
    Folders = varargin;
end
for j=1:length(Folders)
    if(exist([Folders{j} '/info.mat'],'file'))
        load([Folders{j} '/info.mat']);
        N = numel(Info);
        analysis = cell(N,1);
        for i=1:N
            [folder, file] = fileparts(Info(i).filename);
            
            if(exist([folder '/Results/' file '.mat'],'file'))
                x = load([folder '/Results/' file '.mat']);
                analysis{i} = x.analysis;
            else
                if(exist(Info(i).filename,'file'))
                    analysis{i} = ZeroMaze(Info(i));
                end
            end
        end
        
        if(~exist([Folders{j} '/Results'],'dir'))
            mkdir([Folders{j} '/Results']);
        end
        savefile = [Folders{j} '/Results/ZeroMaze_analysis.mat'];
        save(savefile,'analysis');
        disp(['Saved to ' savefile]);
    end
    
    % Rearrange by tag number
    Tags = cell(N,1);
    for i=1:N
        Tags(i) = {analysis{i}.Info.Tag};
    end
    [~,idx] = sort(Tags);
    % Output to a txt file
    fid = fopen([Folders{j} '/Results/results.txt'],'w');
    
    % Header
    fprintf(fid,'File name\tMouse Tag\tTime to first exit (s)\tTotal Close\t Total Open\tTime Closed1 (s)\tTime Closed2 (s)\t Time Open1 (s) \tTime Open2 (s)\tRisk Assessment\tTotal distance (inch)\tAverage speed (inch/s)\tOpen-to-Close transitions\tClose-to-open transitions\tComplexity\n');
    for i=1:N
        try
            s = analysis{idx(i)};
            c = kolmogorov(s.Location);
            fprintf(fid,'%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d\t%d\t%d\n',s.Info.filename,s.Info.Tag,s.TimeFirstExit,s.TimeClosed1+s.TimeClosed2, s.TimeOpen1+s.TimeOpen2,s.TimeClosed1,s.TimeClosed2,s.TimeOpen1,s.TimeOpen2,s.TotalRA,s.Ambulation(end),s.Speed,s.OC,s.CO,c);
        end
    end
end
fclose(fid);