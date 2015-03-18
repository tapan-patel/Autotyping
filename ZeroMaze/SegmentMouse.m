function Lnew = SegmentMouse(BW)
% Given a thresholded binary image, return the largest labeled image
% BW = imclose(BW,strel('disk',5));
L = bwlabel(BW);

C = regionprops(L,'Area');


[~,IDX] = sort([C.Area],'descend');
if(isempty(IDX))
    Lnew = false(size(BW));
else
    Lnew = false(size(BW));
    Lnew(L==IDX(1))=1;
end
