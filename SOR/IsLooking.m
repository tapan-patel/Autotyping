function decision = IsLooking(xhead,yhead,Vision,~,BW)
% Given the position of head and tail and a direction vector for where
% the mouse is looking, see if an object (BW) is in the mouse's sight.

decision = 0;

% Create 5, 10 and 15o rotation vectors ccw and cw
% R = @(theta) [cos(theta) -sin(theta); sin(theta) cos(theta)];
% Vision5ccw = R(5*pi/180)*Vision;
% Vision5ccw = R(-5*pi/180)*Vision;


% if(BW(floor(COM(2)),floor(COM(1))))
%     decision = 1;
%     return
% end

for i=0:.01:1
    x = xhead+i*Vision(1);
    y = yhead + i*Vision(2);
    
    % Is (x,y) part of BW?
    try
        if(BW(floor(y),floor(x)))
            decision = 1;
          
            return;
        end
    end
%     % 5o roation
%     
%     x = xhead+i*Vision5ccw(1);
%     y = yhead + i*Vision5ccw(2);
%     
%     % Is (x,y) part of BW?
%     try
%         if(BW(floor(y),floor(x)))
%             decision = 1;
%             return;
%         end
%     end
%     % 10o rotation
%     
%     x = xhead+i*Vision10ccw(1);
%     y = yhead + i*Vision10ccw(2);
%     
%     % Is (x,y) part of BW?
%     try
%         if(BW(floor(y),floor(x)))
%             decision = 1;
%             return;
%         end
%     end
%     % 15o rotation
%     
%     x = xhead+i*Vision15ccw(1);
%     y = yhead + i*Vision15ccw(2);
%     
%     % Is (x,y) part of BW?
%     try
%         if(BW(floor(y),floor(x)))
%             decision = 1;
%             return;
%         end
%     end
%     % Now do cw rotations at 5, 10 and 15
%     
    % 5o roation
   
%     x = xhead+i*Vision5ccw(1);
%     y = yhead + i*Vision5ccw(2);
%     
%     % Is (x,y) part of BW?
%     try
%         if(BW(floor(y),floor(x)))
%             decision = 1;
%             return;
%         end
%     end
%     % 10o rotation
%  
%     x = xhead+i*Vision10ccw(1);
%     y = yhead + i*Vision10ccw(2);
%     
%     % Is (x,y) part of BW?
%     try
%         if(BW(floor(y),floor(x)))
%             decision = 1;
%             return;
%         end
%     end
%     % 15o rotation
%     
%     x = xhead+i*Vision15ccw(1);
%     y = yhead + i*Vision15ccw(2);
%     
%     % Is (x,y) part of BW?
%     try
%         if(BW(floor(y),floor(x)))
%             decision = 1;
%             return;
%         end
%     end
end