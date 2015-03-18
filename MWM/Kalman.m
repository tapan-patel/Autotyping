function COM_est = Kalman(COM)
COM_est = zeros(size(COM));
% define the filter
x = [ 0; 0; 0; 0 ];
F = [ 1 0 1 0; ...
    0 1 0 1; ...
    0 0 1 0; ...
    0 0 0 1];

Q = [ 1/4  0  1/2  0  ; ...
       0  1/4  0  1/2 ; ...
      1/2  0  1   0  ; ...
       0  1/2  0   1  ] * (.1)^2;
H = [1 0 0 0; 0 1 0 0];
R = eye(2) * 15^2;
P = eye(4) * 1e6;

for i=1:size(COM,1)
    x1 = COM(i,1);
    y1 = COM(i,2);
    z = double([x1; y1]);
     % step 1: predict
     [x,P] = kalman_predict(x,P,F,Q);
      % step 2: update (if measurement exists)
    if all(z > 0)
        [x,P] = kalman_update(x,P,z,H,R);
    end
 
     est_z = H*x;
    est_x1 = est_z(1);
    est_y1 = est_z(2);
    COM_est(i,:) = [est_x1 est_y1];
end