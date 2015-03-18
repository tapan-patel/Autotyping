function analysis = SORBatch(varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania
% Batch process files that have been initialized by InitializeSORFiles.m -
% include the absolute folder name in Read_FNames.m
warning off
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

% fid_log = fopen(['SOR_' date '.log'],'w');
%%
Info = [];
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
            if(exist([folder '/SOR_results/' vidname '.mat'],'file'))
                s = load([folder '/SOR_results/' vidname '.mat']);
                analysis{i} = s.analysis;
            else
                analysis{i} = SOR(Info(idx(i)));
            end
        end
        
        %         analysis = analysis(1:length(idx));
        % Save
        % If SOR_results directory does not exist, create it
        if(~exist([Folders{j} '/SOR_results'],'dir'))
            mkdir([Folders{j} '/SOR_results']);
        end
        savefile = [Folders{j} '/SOR_results/SORanalysis.mat'];
        save(savefile,'analysis');
    else
        error([Folders{j} '/info.mat does not exist. Run SORGUI first']);
    end
    intervals = Info(1).duration/(60*5);
    % Output results to a txt file in /SOR_results directory
    fid = fopen([Folders{j} '/SOR_results/results.txt'],'w');
    fprintf(fid,'Filename \t Mouse Tag \t Glass Time (s) \t Metal Time (s) \t Cylinder Time (s) \t Total Ambulation (inch)');
    for i=1:intervals
        fprintf(fid,'\tTime in outer %i',i);
    end
    for i=1:intervals
        fprintf(fid,'\tTime in inner %i',i);
    end
    
    fprintf(fid,'\n');
    for i=1:length(analysis)
        s = analysis{i};
        %         try
        %         Ambulation = sum(s.PathLength);
        if(s.Info.LeftMouse && s.Info.LeftObjects)
            if(isfield(s.Info,'Novel') && ~isempty(s.Info.Novel))
                Novel = zeros(6,1);
                for m=1:length(s.Info.Novel)
                    Novel(m) = s.Info.Novel(m);
                end
                if(Novel(1))
                    TimeGlassLeft = sprintf('%.2f**',s.TimeGlassLeft);
                else
                    TimeGlassLeft = sprintf('%.2f',s.TimeGlassLeft);
                end
                if(Novel(2))
                    TimeMetalLeft = sprintf('%.2f**',s.TimeMetalLeft);
                else
                    TimeMetalLeft = sprintf('%.2f',s.TimeMetalLeft);
                end
                if(Novel(3))
                    TimeCylinderLeft = sprintf('%.2f**',s.TimeCylinderLeft);
                else
                    TimeCylinderLeft = sprintf('%.2f',s.TimeCylinderLeft);
                end
                
                fprintf(fid,'%s \t %s \t %s \t %s \t %s \t% .2f',s.filename,s.Info.LeftTag,TimeGlassLeft,TimeMetalLeft,TimeCylinderLeft,...
                    s.LeftTotalDistance);
            else
                fprintf(fid,'%s \t %s \t %.2f \t %.2f \t %.2f \t %.2f',s.filename,s.Info.LeftTag,s.TimeGlassLeft,s.TimeMetalLeft,s.TimeCylinderLeft,...
                    s.LeftTotalDistance);
            end
            
            for k=1:length(s.LeftOuter)
                fprintf(fid,'\t%.2f',s.LeftOuter(k));
            end
            for k=1:length(s.LeftInner)
                fprintf(fid,'\t%.2f',s.LeftInner(k));
            end
            
            
            fprintf(fid,'\n');
        end
        if(s.Info.RightMouse && s.Info.RightObjects)
            if(isfield(s.Info,'Novel') && ~isempty(s.Info.Novel))
                Novel = zeros(6,1);
                for m=1:length(s.Info.Novel)
                    Novel(m) = s.Info.Novel(m);
                end
                if(Novel(4))
                    TimeGlassRight = sprintf('%.2f**',s.TimeGlassRight);
                else
                    TimeGlassRight = sprintf('%.2f',s.TimeGlassRight);
                end
                if(Novel(5))
                    TimeMetalRight = sprintf('%.2f**',s.TimeMetalRight);
                else
                    TimeMetalRight = sprintf('%.2f',s.TimeMetalRight);
                end
                if(Novel(6))
                    TimeCylinderRight = sprintf('%.2f**',s.TimeCylinderRight);
                else
                    TimeCylinderRight = sprintf('%.2f',s.TimeCylinderRight);
                end
                fprintf(fid,'%s \t %s \t %s \t %s \t%s \t %.2f',s.filename,s.Info.RightTag,TimeGlassRight,TimeMetalRight,TimeCylinderRight,...
                    s.RightTotalDistance);
            else
                fprintf(fid,'%s \t %s \t %.2f \t %.2f \t%.2f\t%.2f',s.filename,s.Info.RightTag,s.TimeGlassRight,s.TimeMetalRight,s.TimeCylinderRight,...
                    s.RightTotalDistance);
            end
            
            for k=1:length(s.RightOuter)
                fprintf(fid,'\t%.2f',s.RightOuter(k));
            end
            for k=1:length(s.RightInner)
                fprintf(fid,'\t%.2f',s.RightInner(k));
            end
            
            fprintf(fid,'\n');
            
        end
        if(s.Info.LeftMouse && ~s.Info.LeftObjects)
            
            fprintf(fid,'%s \t %s \t -1\t -1\t%.2f',s.filename,s.Info.LeftTag,s.LeftTotalDistance);
            
            for k=1:length(s.LeftOuter)
                fprintf(fid,'\t%.2f',s.LeftOuter(k));
            end
            for k=1:length(s.LeftInner)
                fprintf(fid,'\t%.2f',s.LeftInner(k));
            end
            
            fprintf(fid,'\n');
            
        end
        if(s.Info.RightMouse && ~s.Info.RightObjects)
            
            fprintf(fid,'%s \t %s \t -1 \t -1\t%.2f',s.filename,s.Info.RightTag,s.RightTotalDistance);
            
            for k=1:length(s.RightOuter)
                fprintf(fid,'\t%.2f',s.RightOuter(k));
            end
            for k=1:length(s.RightInner)
                fprintf(fid,'\t%.2f',s.RightInner(k));
            end
            
            fprintf(fid,'\n');
        end
        %         end
    end
    fclose(fid);
    
    %     end
end
CompileBouts(analysis);
% fclose(fid_log);