function Iref = GetRefFrame(abs_mv_name,start_idx)
% Given absolute movie name, read it frame by frame and average to deduce
% the background
disp(['Reading file: ' abs_mv_name]);
vid = VideoReader(abs_mv_name);
if(~vid.NumberOfFrames)
    read(vid,Inf);
end
frames = vid.NumberOfFrames;

Istack = zeros(vid.Height,vid.Width);

for i=start_idx:frames
    
    V = mmread([abs_mv_name],i);
    Istack = Istack + double(rgb2gray(V(end).frames(end).cdata));
% Istack = Istack + double(rgb2gray(V(end).frames.cdata));
end
Iref = uint8(Istack/frames);