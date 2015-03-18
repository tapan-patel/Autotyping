function YMazeBatch(varargin)
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
     if(exist([Folders{j} '/info.mat']))
        load([Folders{j} '/info.mat']);
        N = numel(Info);
        analysis = cell(N,1);
        for i=1:N
                analysis{i} = YMaze(Info(i));
        end
     
        if(~exist([Folders{j} '/Results'],'dir'))
            mkdir([Folders{j} '/Results']);
        end
        savefile = [Folders{j} '/Results/YMaze_analysis.mat'];
        save(savefile,'analysis');
        disp(['Saved to ' savefile]);
     end
     
     % Rearrange by tag number
     Tags = zeros(N,1);
     
     [~,idx] = sort(Tags);
     % Output to a txt file
      fid = fopen([Folders{j} '/Results/results.txt'],'w');
      
      % Header
      fprintf(fid,'File name\tTime to first arm entry (s)\tTime Left (s)\tTime Right (s)\tTime Stem (s)\tTime Neutral (s)\tTotal distance (inch)\tStem -> Right\tStem -> Left\tRight -> Left\tRight -> Stem\tLeft -> Right\tLeft -> Stem\tPattern\t# Spontaneous Transitions\n');
      for i=1:N
          s = analysis{idx(i)};
          fprintf(fid,'%s\t %f\t %f\t %f\t %f\t %f\t %f\t %d\t %d\t %d\t %d\t %d\t %d\t%s\t%d\n',s.Info.filename,s.FirstExit,s.TimeLeft,s.TimeRight,s.TimeStem,s.TimeNeutral,s.Ambulation(end),s.Stem_Right,s.Stem_Left,s.Right_Left,s.Right_Stem,s.Left_Right,s.Left_Stem,s.Pattern,s.SpontaneousTransitions);
      end
      fclose(fid);
end
     