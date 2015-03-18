function angle = GetAngle2(x_o,y_o,x_c,y_c)
% Define a 0 degree as the horizontal +x axis from the center
x1 = 1;
y1 = 0;
% Bring the vector to origin
x_o = x_o-x_c;
y_o = y_c-y_o;
b = [x_o y_o]; b = b/norm(b);
x2 = b(1); y2 = b(2);

angle = (atan2(x1*y2-x2*y1,x1*x2+y1*y2))*180/pi;
% r = sqrt( (x_c-x_o)^2 + (y_c-y_o)^2);
% if(x_o<x_c && y_o>y_c)
%     theta= acosd( (x_o-x_c)/r);
% elseif(x_o>x_c && y_o>y_c)
%     theta = asind( (y_o-y_c)/r);
% elseif(x_o<x_c && y_o<y_c)
%     theta = abs( asind( (y_o-y_c)/r));
% elseif(x_o>x_c && y_o<y_c)
%     theta = acosd( (x_o-x_c)/r);
% end
