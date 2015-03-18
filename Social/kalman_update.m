function [x,P] = kalman_update(x,P,z,H,R)
    y = z - H*x; %measurement error/innovation
    S = H*P*H' + R; %measurement error/innovation covariance
    K = P*H'*inv(S); %optimal Kalman gain
    x = x + K*y; %updated state estimate
    P = (eye(size(x,1)) - K*H)*P; %updated estimate covariance
end