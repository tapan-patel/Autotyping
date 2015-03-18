function numFrames = mmcount(filename)
% Return the total number of frames in a video file
if(~exist(filename,'file'))
    error([filename ' does not exist']);
end
video = mmread(filename,1);
video = video(end);
if video.nrFramesTotal > 0
    % A positive value of nrFramesTotal means it is a valid value for
    % number of frames.
    numFrames = video.nrFramesTotal;
else
    % If video.nrFramesTotal is negative, it is an *estimated* number of
    % frames. Read past the end of the video (using the estimated number of
    % frames); the value of nrFramesTotal will then be accurate. This code
    % suggested by Micah Richert, author of the mmread program.
    
    % Read a frame number that is greater than than the estimated number of
    % frames to get an accurate number of frames back from mmread.
    estNumFrames = -video.nrFramesTotal;
    largeFrameNum = ceil(estNumFrames*1.01);
    warning off mmread:general
    video = mmread(filename,largeFrameNum);
    warning on mmread:general
    numFrames = video.nrFramesTotal;
end % if

% Return NaN if the search for the number of frames failed.
if numFrames<1
    numFrames = NaN;
end 
