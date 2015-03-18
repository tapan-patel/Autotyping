function CompileBouts(analysis)
% Given an output from SORBatch, SORanalysis, loop through each video and
% extract the interaction bouts for each object. There could be either 2 or
% 3 objects and right and left mouse.
Ncells = size(analysis,1);
for i=1:Ncells
    s = analysis{i};
    vidname = s.Info.filename;
    if(~exist(vidname,'file'))
        error([vidname ' does not exist']);
        break;
    end
   
    h=msgbox(['Gathering interaction bouts for ' vidname]);
     try
    if(isfield(s,'TimeGlassLeft') && ~isempty(s.TimeGlassLeft))
        C = regionprops(s.Info.ROIs.mask_left,'BoundingBox');
        idx = find(s.GlassLeft);
        if(~isempty(idx))
        V = mmread(vidname,idx);
        % Reduce the size and store the frames
        V = V(end);
        for k=1:length(V.frames)
            V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
        end
        s.GlassLeftBouts = V;
        s.GlassLeft_L = bwlabel(s.GlassLeft);
        else
            s.GlassLeftBouts = [];
        s.GlassLeft_L = [];
        end
    end
    if(isfield(s,'TimeMetalLeft') && ~isempty(s.TimeMetalLeft))
        C = regionprops(s.Info.ROIs.mask_left,'BoundingBox');
        idx = find(s.MetalLeft);
        if(~isempty(idx))
        V = mmread(vidname,idx);
        % Reduce the size and store the frames
        V = V(end);
        for k=1:length(V.frames)
            V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
        end
        s.MetalLeftBouts = V;
        s.MetalLeft_L = bwlabel(s.MetalLeft);
        else
              s.MetalLeftBouts = [];
        s.MetalLeft_L = [];
        end
    end
    if(isfield(s,'TimeCylinderLeft') && ~isempty(s.TimeCylinderLeft))
        C = regionprops(s.Info.ROIs.mask_left,'BoundingBox');
        idx = find(s.CylinderLeft);
        if(~isempty(idx))
        V = mmread(vidname,idx);
        % Reduce the size and store the frames
        V = V(end);
        for k=1:length(V.frames)
            V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
        end
        s.CylinderLeftBouts = V;
        s.CylinderLeft_L = bwlabel(s.CylinderLeft);
        else
            s.CylinderLeftBouts = [];
        s.CylinderLeft_L = [];
        end
    end
    if(isfield(s,'TimeGlassRight') && ~isempty(s.TimeGlassRight))
        C = regionprops(s.Info.ROIs.mask_right,'BoundingBox');
        idx = find(s.GlassRight);
        if(~isempty(idx))
        V = mmread(vidname,idx);
        % Reduce the size and store the frames
        V = V(end);
        for k=1:length(V.frames)
            V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
        end
        s.GlassRightBouts = V;
        s.GlassRight_L = bwlabel(s.GlassRight);
        else
            s.GlassRightBouts = [];
        s.GlassRight_L = [];
        end
    end
    if(isfield(s,'TimeMetalRight') && ~isempty(s.TimeMetalRight))
        C = regionprops(s.Info.ROIs.mask_right,'BoundingBox');
        idx = find(s.MetalRight);
        if(~isempty(idx))
        V = mmread(vidname,idx);
        % Reduce the size and store the frames
        V = V(end);
        for k=1:length(V.frames)
            V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
        end
        s.MetalRightBouts = V;
        s.MetalRight_L = bwlabel(s.MetalRight);
        else
            s.MetalRightBouts = [];
        s.MetalRight_L = [];
        end
    end
    if(isfield(s,'TimeCylinderRight') && ~isempty(s.TimeCylinderRight))
        C = regionprops(s.Info.ROIs.mask_right,'BoundingBox');
        idx = find(s.CylinderRight);
        if(~isempty(idx))
        V = mmread(vidname,idx);
        % Reduce the size and store the frames
        V = V(end);
        for k=1:length(V.frames)
            V.frames(k).cdata = imresize(imcrop(rgb2gray(V.frames(k).cdata),C.BoundingBox),.5);
        end
        s.CylinderRightBouts = V;
        s.CylinderRight_L = bwlabel(s.CylinderRight);
        else
            s.CylinderRightBouts = [];
        s.CylinderRight_L = [];
        end
    end
    % Save this structure as a separate file
    [f1,f2] = fileparts(vidname);
    if(~exist([f1 '/SOR_Bouts'],'dir'))
        mkdir([f1 '/SOR_Bouts']);
    end
    fname = sprintf('%s/SOR_Bouts/%s.mat',f1,f2);
    save(fname,'s','-v7.3');
    disp(['Bouts saved to ' fname]);
    delete(h);
    catch
        msg = sprintf('Out of memory! Could not extract freezing bouts for %s\nYou will not be able to use the "inspect" GUI for this video.',vidname);
        msgbox(msg);
         delete(h);
    end
end
