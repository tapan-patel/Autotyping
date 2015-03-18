function decision = IsLooking(xhead,yhead,Vision,BW,COM)
% Given the position of head and tail and a direction vector for where
% the mouse is looking, see if an object (BW) is in the mouse's sight.

decision = 0;
% Find the endpoints of L
% skel = bwmorph(L,'skel',Inf);
% endpts = bwmorph(skel,'endpoints');
% idx = find(endpts);
% for i=1:length(idx)
%     [x,y] = ind2sub(size(L),idx(i));
%     if(BW(floor(COM(2)),floor(COM(1))))
%         decision = 1;
% %         break;
%     end
% end
% Create 5, 10 and 15o rotation vectors ccw and cw
% R = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)];
% Vision5ccw = R(5*pi/180)*Vision;
% Vision5ccw = R(-5*pi/180)*Vision;


% if(BW(floor(COM(2)),floor(COM(1))))
%     decision = 1;
%     return
% end

%%%%%%%%%%% COMMENTED OUT ************
x = zeros(3,1);
y = zeros(3,1);
x(1) = xhead+0*Vision(1);
y(1) = yhead + 0*Vision(2);
x(2) = xhead+0.5*Vision(1);
y(2) = yhead + 0.5*Vision(2);
x(3) = xhead+1.0*Vision(1);
y(3) = yhead + 1.0*Vision(2);
% Is (x,y) part of BW?
for i=1:3
    try
        if(BW(floor(y(i)),floor(x(i))) && BW(floor(COM(2)),floor(COM(1))))
            decision = 1;
            
            return;
        end
    end
end
% for i=0:.01:1
%     x = xhead+i*Vision(1);
%     y = yhead + i*Vision(2);
%     
%     % Is (x,y) part of BW?
%     try
%         if(BW(floor(y),floor(x)) && BW(floor(COM(2)),floor(COM(1))))
%             decision = 1;
%           
%             return;
%         end
%     end
% 
% end
%%%%%%%%%%%%%%%%%%%%%%% COMMENTED OUT END %%%%%%%%%%%%%
% If the centroid is within an inch of the boundary of the object, count it
% tic
% B = bwboundaries(BW);
% d = [];
% for k=1:length(B)
%     N = zeros(size(B{k},1),1);
%     for p = 1:length(N)
%         x = B{k}(p,2); y = B{k}(p,1);
%         N(p) = sqrt( (COM(1)-x)^2 + (COM(2)-y)^2);
%     end
%     d = [d min(N)];
% end
% if(d<px)
%     decision = 1;
% end
% toc
% 
% tic
% BW_dil = imdilate(BW,strel('disk',floor(px),0));



% if(BW(floor(COM(2)),floor(COM(1))))
%     decision = 1;
% end
% toc