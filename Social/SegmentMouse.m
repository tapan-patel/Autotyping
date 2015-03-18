function Lnew = SegmentMouse(BW,BWobject1, BWobject2)
%#codegen
% Given a thresholded binary image, return the largest labeled image
BW = imclose(BW,strel('disk',5));
BW = imfill(BW,'holes');
L = bwlabel(BW);

% if(max(L(:))>1)
% BW = connCompWindow(BW,5);
% end
% L = bwlabel(BW);

C = regionprops(BW,'Area','Centroid');


[A,IDX] = sort([C.Area],'descend');
if(isempty(IDX))
    Lnew = false(size(BW));
elseif(length(IDX)>1 && A(2)>200)
    
    x = floor(C(IDX(1)).Centroid(1));
    y = floor(C(IDX(1)).Centroid(2));
    if(BWobject1(y,x) || BWobject2(y,x))
        Lnew = L==IDX(2);
    else
        Lnew = L==IDX(1);
    end
else
    Lnew = L==IDX(1);
end
    
%     if(session==1)
%         Lnew = L==IDX(1);
%     else
%         if(length(IDX)>1) % More than one object
%             % Tail is probably cut off - make sure that the second object is
%             % sufficiently big
%             if(A(2)/A(1)>.05)
%                 % Body = 1, tail = 2
%                 Lnew2 = zeros(size(L));
%                 Lnew2(L==IDX(1)) = 1;
% %                 Lnew2(L==IDX(2)) = 2;
%                 Lnew = Lnew2;
%                 
%                 
%             else
%                 Lnew = L==IDX(1);
%             end
%         else
%             Lnew = L==IDX(1);
%         end
%     end
% end
% 
