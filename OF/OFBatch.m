function analysis = OFBatch(varargin)
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
        for i=1:length(idx)
%                 fprintf(fid_log,'Processing %s\n', Info(idx(i)).filename);
                [folder,vidname] = fileparts(Info(idx(i)).filename);
                if(exist([folder '/OF_results/' vidname '.mat'],'file'))
                    s = load([folder '/OF_results/' vidname '.mat']);
                    analysis{i} = s.analysis;
                else
                    analysis{i} = OF(Info(idx(i)));
                end
        end
        

%         analysis = analysis(1:length(idx));
        % Save
        % If SOR_results directory does not exist, create it
        if(~exist([Folders{j} '/OF_results'],'dir'))
            mkdir([Folders{j} '/OF_results']);
        end
        savefile = [Folders{j} '/OF_results/OFanalysis.mat'];
        save(savefile,'analysis');
    else
        error([Folders{j} '/info.mat does not exist. Run SORGUI first']);
    end
    intervals = Info(1).duration/(60*5);
    % Output results to a txt file in /SOR_results directory
    fid = fopen([Folders{j} '/OF_results/results.txt'],'w');
    fprintf(fid,'Filename \t Mouse Tag \t Total Ambulation (inch)');
    for i=1:intervals
        fprintf(fid,'\tTime in outer %i',i);
    end
    for i=1:intervals
        fprintf(fid,'\tTime in inner %i',i);
    end
    for i=1:intervals
        fprintf(fid,'\tThigmotaxis %i',i);
    end
    fprintf(fid,'\n');
    for i=1:length(analysis)
        s = analysis{i};
%         try
%         Ambulation = sum(s.PathLength);
          
            fprintf(fid,'%s \t %s \t %.2f',s.filename,s.Info.Tag,s.TotalDistance);
           
            for k=1:length(s.Outer)
                fprintf(fid,'\t%.2f',s.Outer(k));
            end
            for k=1:length(s.Inner)
                fprintf(fid,'\t%.2f',s.Inner(k));
            end
            
            for k=1:length(s.Thigmotaxis)
                fprintf(fid,'\t%.2f',s.Thigmotaxis(k));
            end
            fprintf(fid,'\n');
            
        
    end
    fclose(fid);
    
    %     end
end

% fclose(fid_log);
