function analysis = SocialBatch(varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania

% Batch process files that have been initialized by InitializeSORFiles.m -
% include the absolute folder name in Read_FNames.m
warning off
if(isempty(which('mmread')))
    addpath('../mmread');
end
if(nargin==0)
    Info = [];
    Folders = Read_FNames;
else
    Folders = varargin;
end
%%
Info = [];
for j=1:size(Folders,1)

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
%             try
                %                 fprintf(fid_log,'Processing %s\n', Info(idx(i)).filename);
                [folder,vidname] = fileparts(Info(idx(i)).filename);
                if(exist([folder '/SI_results/' vidname '.mat'],'file'))
                    s = load([folder '/SI_results/' vidname '.mat']);
                    analysis{i} = s.analysis;
                else
                    analysis{i} = Social(Info(idx(i)));
                end
%             end
        end
        
        %         analysis = analysis(1:length(idx));
        % Save
        % If SI_results directory does not exist, create it
        if(~exist([Folders{j} '/SI_results'],'dir'))
            mkdir([Folders{j} '/SI_results']);
        end
        savefile = [Folders{j} '/SI_results/SI_analysis.mat'];
        save(savefile,'analysis');
    else
        error([Folders{j} '/info.mat does not exist. Run SocialGUI first']);
    end
    
    
    %     intervals = duration/(60*5);
    %     % Output results to a txt file in /SOR_results directory
    fid = fopen([Folders{j} '/SI_results/results.txt'],'w');
    fprintf(fid,'Filename \t Mouse Tag \t Left cylinder interaction time (0-10min) (s) \t Right cylinder interaction time (0-10min) (s) \t Left chamber time (0-10min) (s) \t Right chamber time (0-10min) (s) \t Middle chamber time (0-10min) (s) \t Total distance (0-10min) \t Left cylinder interaction time (10-20min) (s) \t Right cylinder interaction time (10-20min) (s) \t Left chamber time (10-20min) (s) \t Right chamber time (10-20min) (s) \t Middle chamber time (10-20min) (s) \t Total distance (10-20min)\n');
    
    for i=1:length(analysis)
        s = analysis{i};
        try
            if(s.Info.LeftMouse)
                if(isfield(s.Info,'Novel') && ~isempty(s.Info.Novel))
                    Novel = zeros(8,1);
                    for m=1:length(s.Info.Novel)
                        Novel(m) = s.Info.Novel;
                    end
                    s.Info.Novel = Novel;
                    
                    if(s.Info.Novel(1))
                        LeftTime1 = sprintf('%.2f**',s.Time_Top_Left1);
                    else
                        LeftTime1 = sprintf('%.2f',s.Time_Top_Left1);
                    end
                    if(s.Info.Novel(2))
                        RightTime1 = sprintf('%.2f**',s.Time_Top_Right1);
                    else
                        RightTime1 = sprintf('%.2f',s.Time_Top_Right1);
                    end
                    if(s.Info.Novel(3))
                        LeftTime2 = sprintf('%.2f**',s.Time_Top_Left2);
                    else
                        LeftTime2 = sprintf('%.2f',s.Time_Top_Left2);
                    end
                    if(s.Info.Novel(4))
                        RightTime2 = sprintf('%.2f**',s.Time_Top_Right2);
                    else
                        RightTime2 = sprintf('%.2f',s.Time_Top_Right2);
                    end
                    fprintf(fid,'%s \t %s \t %s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \t %s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \n',...
                        s.filename, s.Info.LeftTag, LeftTime1, RightTime1,s.Time_Top_LeftChamber1,s.Time_Top_RightChamber1,s.Time_Top_MiddleChamber1,...
                        s.Distance_top1, LeftTime2, RightTime2, s.Time_Top_LeftChamber2,s.Time_Top_RightChamber2,s.Time_Top_MiddleChamber2,s.Distance_top2);
                else
                    fprintf(fid,'%s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \n',...
                        s.filename, s.Info.LeftTag, s.Time_Top_Left1, s.Time_Top_Right1,s.Time_Top_LeftChamber1,s.Time_Top_RightChamber1,s.Time_Top_MiddleChamber1,...
                        s.Distance_top1, s.Time_Top_Left2, s.Time_Top_Right2, s.Time_Top_LeftChamber2,s.Time_Top_RightChamber2,s.Time_Top_MiddleChamber2,s.Distance_top2);
                end
            end
        end
        try
            if(s.Info.RightMouse)
                if(isfield(s.Info,'Novel') && ~isempty(s.Info.Novel))
                    Novel = zeros(8,1);
                    for m=1:length(s.Info.Novel)
                        Novel(m) = s.Info.Novel;
                    end
                    s.Info.Novel = Novel;
                    if(s.Info.Novel(5))
                        LeftTime1 = sprintf('%.2f**',s.Time_Bottom_Left1);
                    else
                        LeftTime1 = sprintf('%.2f',s.Time_Bottom_Left1);
                    end
                    if(s.Info.Novel(6))
                        RightTime1 = sprintf('%.2f**',s.Time_Bottom_Right1);
                    else
                        RightTime1 = sprintf('%.2f',s.Time_Bottom_Right1);
                    end
                    if(s.Info.Novel(7))
                        LeftTime2 = sprintf('%.2f**',s.Time_Bottom_Left2);
                    else
                        LeftTime2 = sprintf('%.2f',s.Time_Bottom_Left2);
                    end
                    if(s.Info.Novel(8))
                        RightTime2 = sprintf('%.2f**',s.Time_Bottom_Right2);
                    else
                        RightTime2 = sprintf('%.2f',s.Time_Bottom_Right2);
                    end
                    fprintf(fid,'%s \t %s \t %s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \t %s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \n',...
                        s.filename, s.Info.RightTag, LeftTime1, RightTime1,s.Time_Bottom_LeftChamber1,s.Time_Bottom_RightChamber1,s.Time_Bottom_MiddleChamber1,...
                        s.Distance_bottom1, LeftTime2, RightTime2, s.Time_Bottom_LeftChamber2,s.Time_Bottom_RightChamber2,s.Time_Bottom_MiddleChamber2,s.Distance_bottom2);
                else
                    fprintf(fid,'%s \t %s \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \t %.2f \n',...
                        s.filename, s.Info.RightTag, s.Time_Bottom_Left1, s.Time_Bottom_Right1,s.Time_Bottom_LeftChamber1,s.Time_Bottom_RightChamber1,s.Time_Bottom_MiddleChamber1,...
                        s.Distance_bottom1, s.Time_Bottom_Left2, s.Time_Bottom_Right2, s.Time_Bottom_LeftChamber2,s.Time_Bottom_RightChamber2,s.Time_Bottom_MiddleChamber2,s.Distance_bottom2);
                end
            end
        end
    end
    fclose(fid);
end

CompileBouts(analysis);
