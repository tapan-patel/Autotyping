function BarnesBatch(varargin)
% Citation: Patel TP, Gullotti DM, et al (2014). 
% An open-source toolbox for automated phenotyping of mice in behavioral tasks. 
% Front. Behav. Neurosci. 8:349. doi: 10.3389/fnbeh.2014.00349
% www.seas.upenn.edu/~molneuro/autotyping.html
% Copyright 2014, Tapan Patel PhD, University of Pennsylvania
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
        % Remove duplicates
        files = cell(N,1);
        for i=1:N
            [~,files{i}] = fileparts(Info(i).filename);
        end
        [~,idx] = unique(files);
        analysis = cell(length(idx),1);
        for i=1:length(idx)
            vidname = files{idx(i)};
            
            if(exist([Folders{j} '/BarnesMaze_results/' vidname '.mat'],'file'))
                s = load([Folders{j} '/BarnesMaze_results/' vidname '.mat']);
                analysis{i} = s.analysis;
            else
                analysis{i} = BarnesMaze(Info(idx(i)));
            end
        end
        if(~exist([Folders{j} '/BarnesMaze_results'],'dir'))
            mkdir([Folders{j} '/BarnesMaze_results']);
        end
        savefile = [Folders{j} '/BarnesMaze_results/BManalysis.mat'];
        save(savefile,'analysis');
        
        fid = fopen([Folders{j} '/BarnesMaze_results/results.txt'],'w');
        fprintf(fid,'Filename \t Mouse Tag \t Latency to escape(s) \t Distance to escape (inch) \t Total Ambulation (inch) \t # of errors \t Time in quadrant 1 \t Time in quadrant 2 \t Time in quadrant 3 \t Time in quadrant 4\n');
        for i=1:length(analysis)
            try
                s = analysis{i};
                fprintf(fid,'%s\t%s\t%.2f\t%.2f\t%.2f\t%d\t%.2f\t%.2f\t%.2f\t%.2f\n',s.Info.filename,s.Info.MouseTag,s.latency,s.dist_to_escape,s.total_dist,s.errors,s.Time_in_quadrants(1),s.Time_in_quadrants(2),s.Time_in_quadrants(3),s.Time_in_quadrants(4));
                
                % Output nosepokes by ROI in a separate file
                [~,f] = fileparts(s.Info.filename);
                fid_nose = fopen([Folders{j} '/BarnesMaze_results/' f '.txt'],'w');
                fprintf(fid_nose,'ROI \t Total nosepokes \t Duration of nosepokes \t time-stamp (duration)\n');
                for k=1:9
                    fprintf(fid_nose,'%d\t%d\t%.2f\t',k,length(s.NosePoke_timestamps{k}),sum(s.NosePoke_durations{k}));
                    for m=1:length(s.NosePoke_timestamps{k})
                        fprintf(fid_nose,'%.1f (%.1f)\t',s.NosePoke_timestamps{k}(m),s.NosePoke_durations{k}(m));
                    end
                    fprintf(fid_nose,'\n');
                end
                fprintf(fid_nose,'Target\t%d\t%.2f\t',length(s.NosePoke_timestamps{20}),sum(s.NosePoke_durations{20}));
                for k=1:length(s.NosePoke_timestamps{20})
                    fprintf(fid_nose,'%.1f (%.1f)\t',s.NosePoke_timestamps{20}(k),s.NosePoke_durations{20}(k));
                end
                fprintf(fid_nose,'\n');
                for k=18:-1:10
                    fprintf(fid_nose,'%d\t%d\t%.2f\t',k-19,length(s.NosePoke_timestamps{k}),sum(s.NosePoke_durations{k}));
                    for m=1:length(s.NosePoke_timestamps{k})
                        fprintf(fid_nose,'%.1f (%.1f)\t',s.NosePoke_timestamps{k}(m),s.NosePoke_durations{k}(m));
                    end
                    fprintf(fid_nose,'\n');
                end
                fprintf(fid_nose,'Opposite\t%d\t%.2f\t',length(s.NosePoke_timestamps{19}),sum(s.NosePoke_durations{19}));
                for k=1:length(s.NosePoke_timestamps{19})
                    fprintf(fid_nose,'%.1f (%.1f)\t',s.NosePoke_timestamps{19}(k),s.NosePoke_durations{19}(k));
                end
                fprintf(fid_nose,'\n');
                fclose(fid_nose);
            end
        end
    end
    fclose(fid);
end
