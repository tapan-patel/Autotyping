function Bkg = EstimateBackground(abs_mv_path,frames,start_idx)
% Estimates the background image frame by randomly sampling 100 frames and
% computing pixel-wise mode.
indices = randsample(frames-start_idx,min([100 frames-start_idx]))+(start_idx);
indices(indices>frames) = [];
indices = sort(indices);
V = mmread(abs_mv_path,indices); V = V(end);
A = zeros(V.height,V.width,length(V.frames),'uint8');
for i=1:length(V.frames)
    A(:,:,i) = uint8(rgb2gray(V.frames(i).cdata));
end
Bkg = mode(double(A),3);

% Fix any 0's - this arises if the mouse sits in one location for most of
% the video and is incorporated as part of the background
Bkg = double(Bkg);
Bkg(Bkg<10) = nan;
Bkg = uint8(inpaint_nans(Bkg,2));
