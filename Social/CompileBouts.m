function CompileBouts(analysis)
% Given an output from SORBatch, SORanalysis, loop through each video and
% extract the interaction bouts for each object. There could be either 2 or
% 3 objects and right and left mouse.
Ncells = size(analysis,1);
for i=1:Ncells
    s = analysis{i};
    if(~isempty(s))
        vidname = s.Info.filename;
        if(~exist(vidname,'file'))
            error([vidname ' does not exist']);
            break;
        end
        try
        h=msgbox(['Gathering interaction bouts for ' vidname]);
        if(s.Info.LeftMouse)
            C = regionprops(s.Info.ROIs.surface_top,'BoundingBox');
            if(isfield(s,'end_idx1') && ~isempty(s.end_idx1))
                % Work on the first 10 minutes
                idx = find(s.Looking_TopLeft(1:s.end_idx1));
                V = [];
                L = [];
                if(~isempty(idx))
                    
                    V = mmread(vidname,idx);
                    % Reduce the size and store the frames
                    V = V(end);
                    for k=1:length(V.frames)
                        V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
                    end
                    s.TopLeft1_Bouts = V;
                    L = bwlabel(s.Looking_TopLeft(1:s.end_idx1));
                    L = L(find(L));
                    s.TopLeft1_L = L;
                end
                
                idx = find(s.Looking_TopRight(1:s.end_idx1));
                V = [];
                L = [];
                if(~isempty(idx))
                    
                    V = mmread(vidname,idx);
                    % Reduce the size and store the frames
                    V = V(end);
                    for k=1:length(V.frames)
                        V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
                    end
                    s.TopRight1_Bouts = V;
                    L = bwlabel(s.Looking_TopRight(1:s.end_idx1));
                    L = L(find(L));
                    s.TopRight1_L = L;
                end
            end
            if(isfield(s,'end_idx2') && ~isempty(s.end_idx2))
                % Work on second 10 minute interval now
                s.Looking_TopLeft(1:s.end_idx1) = 0;
                idx = find(s.Looking_TopLeft(1:s.end_idx2));
                V = [];
                L = [];
                if(~isempty(idx))
                    
                    V = mmread(vidname,idx);
                    % Reduce the size and store the frames
                    V = V(end);
                    for k=1:length(V.frames)
                        V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
                    end
                    s.TopLeft2_Bouts = V;
                    L = bwlabel(s.Looking_TopLeft(1:s.end_idx2));
                    L = L(find(L));
                    s.TopLeft2_L = L;
                end
                V = [];
                L = [];
                  s.Looking_TopLeft(1:s.end_idx1) = 0;
                    idx = find(s.Looking_TopRight(1:s.end_idx2));
                if(~isempty(idx))
                    
                    V = mmread(vidname,idx);
                    % Reduce the size and store the frames
                    V = V(end);
                    for k=1:length(V.frames)
                        V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
                    end
                    s.TopRight2_Bouts = V;
                    L = bwlabel(s.Looking_TopRight(1:s.end_idx2));
                    L = L(find(L));
                    s.TopRight2_L = L;
                end
            end
        end
        
        if(s.Info.RightMouse)
            C = regionprops(s.Info.ROIs.surface_bottom,'BoundingBox');
            if(isfield(s,'end_idx1') && ~isempty(s.end_idx1))
                % Work on the first 10 minutes
                idx = find(s.Looking_BottomLeft(1:s.end_idx1));
                V = [];
                L = [];
                if(~isempty(idx))
                    
                    V = mmread(vidname,idx);
                    % Reduce the size and store the frames
                    V = V(end);
                    for k=1:length(V.frames)
                        V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
                    end
                    s.BottomLeft1_Bouts = V;
                    L = bwlabel(s.Looking_BottomLeft(1:s.end_idx1));
                    L = L(find(L));
                    s.BottomLeft1_L = L;
                end
                V = [];
                L = [];
                 idx = find(s.Looking_BottomRight(1:s.end_idx1));
                if(~isempty(idx))
                    V = mmread(vidname,idx);
                    % Reduce the size and store the frames
                    V = V(end);
                    for k=1:length(V.frames)
                        V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
                    end
                    s.BottomRight1_Bouts = V;
                    L = bwlabel(s.Looking_BottomRight(1:s.end_idx1));
                    L = L(find(L));
                    s.BottomRight1_L = L;
                end
            end
            if(isfield(s,'end_idx2') && ~isempty(s.end_idx2))
                % Work on second 10 minute interval now
                s.Looking_BottomLeft(1:s.end_idx1) = 0;
                idx = find(s.Looking_BottomLeft(1:s.end_idx2));
                V = [];
                L = [];
                if(~isempty(idx))
                    
                    V = mmread(vidname,idx);
                    % Reduce the size and store the frames
                    V = V(end);
                    for k=1:length(V.frames)
                        V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
                    end
                    s.BottomLeft2_Bouts = V;
                    L = bwlabel(s.Looking_BottomLeft(1:s.end_idx2));
                    L = L(find(L));
                    s.BottomLeft2_L = L;
                end
                V = [];
                L = [];
                s.Looking_BottomLeft(1:s.end_idx1) = 0;
                    idx = find(s.Looking_BottomRight(1:s.end_idx2));
                if(~isempty(idx))
                    V = mmread(vidname,idx);
                    % Reduce the size and store the frames
                    V = V(end);
                    for k=1:length(V.frames)
                        V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
                    end
                    s.BottomRight2_Bouts = V;
                    L = bwlabel(s.Looking_BottomRight(1:s.end_idx2));
                    L = L(find(L));
                    s.BottomRight2_L = L;
                end
            end
        end
        % Save this structure as a separate file
        [f1,f2] = fileparts(vidname);
        if(~exist([f1 '/Social_Bouts'],'dir'))
            mkdir([f1 '/Social_Bouts']);
        end
        fname = sprintf('%s/Social_Bouts/%s.mat',f1,f2);
        save(fname,'s','-v7.3');
        disp(['Bouts saved to ' fname]);
        delete(h);
        catch
            msg = sprintf('Out of memory! Could not extract social interaction bouts for %s\nYou will not be able to use the "inspect" GUI for this video.',vidname);
        msgbox(msg);
        end
    end
end