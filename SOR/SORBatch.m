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
%             if(exist([folder '/SOR_results/' vidname '.mat'],'file'))
%                 s = load([folder '/SOR_results/' vidname '.mat']);
%                 analysis{i} = s.analysis;
%             else
                analysis{i} = SOR(Info(idx(i)));
%             end
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
    if(~exist('duration','var'))
        try
            duration = analysis{1}.Info.duration;
        catch
            duration = 600;
        end
    end
    intervals = duration/(60*5);
    % Output results to a txt file in /SOR_results directory
    fid = fopen([Folders{j} '/SOR_results/results.txt'],'w');
    fprintf(fid,'Filename \t Mouse Tag \t Glass Time (s) \t Metal Time (s) \t Total Ambulation (inch)');
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
        if(s.Info.LeftMouse && s.Info.LeftObjects)
            if(isfield(s.Info,'Novel') && ~isempty(s.Info.Novel))
                if(length(s.Info.Novel)~=4)
                    Novel = zeros(4,1);
                    for m=1:length(s.Info.Novel)
                        Novel(m) = s.Info.Novel(m);
                    end
                    s.Info.Novel = Novel;
                end
                if(s.Info.Novel(1))
                    GlassTime = sprintf('%.2f**',s.TimeGlassLeft);
                else
                    GlassTime = sprintf('%.2f',s.TimeGlassLeft);
                end
                if(s.Info.Novel(2))
                    MetalTime = sprintf('%.2f**',s.TimeMetalLeft);
                else
                    MetalTime = sprintf('%.2f',s.TimeMetalLeft);
                end
                fprintf(fid,'%s \t %s \t %s \t %s \t%.2f',s.filename,s.Info.LeftTag,GlassTime,MetalTime,...
                    s.LeftTotalDistance);
                
            else
                fprintf(fid,'%s \t %s \t %.2f \t %.2f \t%.2f',s.filename,s.Info.LeftTag,s.TimeGlassLeft,s.TimeMetalLeft,...
                    s.LeftTotalDistance);
            end
            for k=1:length(s.LeftOuter)
                fprintf(fid,'\t%.2f',s.LeftOuter(k)+s.LeftCorners(k));
            end
            for k=1:length(s.LeftInner)
                fprintf(fid,'\t%.2f',s.LeftInner(k)+s.LeftCenter(k));
            end
            
            for k=1:length(s.LeftThigmotaxis)
                fprintf(fid,'\t%.2f',s.LeftThigmotaxis(k));
            end
            fprintf(fid,'\n');
        end
        if(s.Info.RightMouse && s.Info.RightObjects)
            if(isfield(s.Info,'Novel') && ~isempty(s.Info.Novel))
                if(length(s.Info.Novel)~=4)
                    Novel = zeros(4,1);
                    for m=1:length(s.Info.Novel)
                        Novel(m) = s.Info.Novel(m);
                    end
                    s.Info.Novel = Novel;
                end
                if(s.Info.Novel(3))
                    GlassTime = sprintf('%.2f**',s.TimeGlassRight);
                else
                    GlassTime = sprintf('%.2f',s.TimeGlassRight);
                end
                if(s.Info.Novel(4))
                    MetalTime = sprintf('%.2f**',s.TimeMetalRight);
                else
                    MetalTime = sprintf('%.2f',s.TimeMetalRight);
                end
                fprintf(fid,'%s \t %s \t %s \t %s \t%.2f',s.filename,s.Info.RightTag,GlassTime,MetalTime,...
                    s.RightTotalDistance);
            else
                fprintf(fid,'%s \t %s \t %.2f \t %.2f \t%.2f',s.filename,s.Info.RightTag,s.TimeGlassRight,s.TimeMetalRight,...
                    s.RightTotalDistance);
            end
            for k=1:length(s.RightOuter)
                fprintf(fid,'\t%.2f',s.RightOuter(k)+s.RightCorners(k));
            end
            for k=1:length(s.RightInner)
                fprintf(fid,'\t%.2f',s.RightInner(k)+s.RightCenter(k));
            end
            
            for k=1:length(s.RightThigmotaxis)
                fprintf(fid,'\t%.2f',s.RightThigmotaxis(k));
            end
            fprintf(fid,'\n');
            
        end
        if(s.Info.LeftMouse && ~s.Info.LeftObjects)
            
            fprintf(fid,'%s \t %s \t -1\t -1\t%.2f',s.filename,s.Info.LeftTag,s.LeftTotalDistance);
            
            for k=1:length(s.LeftOuter)
                fprintf(fid,'\t%.2f',s.LeftOuter(k)+s.LeftCorners(k));
            end
            for k=1:length(s.LeftInner)
                fprintf(fid,'\t%.2f',s.LeftInner(k)+s.LeftCenter(k));
            end
            
            for k=1:length(s.LeftThigmotaxis)
                fprintf(fid,'\t%.2f',s.LeftThigmotaxis(k));
            end
            fprintf(fid,'\n');
            
        end
        if(s.Info.RightMouse && ~s.Info.RightObjects)
            
            fprintf(fid,'%s \t %s \t -1 \t -1\t%.2f',s.filename,s.Info.RightTag,s.RightTotalDistance);
            
            for k=1:length(s.RightOuter)
                fprintf(fid,'\t%.2f',s.RightOuter(k)+s.RightCorners(k));
            end
            for k=1:length(s.RightInner)
                fprintf(fid,'\t%.2f',s.RightInner(k)+s.RightCenter(k));
            end
            
            for k=1:length(s.RightThigmotaxis)
                fprintf(fid,'\t%.2f',s.RightThigmotaxis(k));
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