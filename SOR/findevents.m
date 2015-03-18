function E = findevents(motion,fps,win)
frames = length(motion);

L = ceil(fps*win); % 10 second window
d = 1; % Displace by 1 frame
E = 10*ones(frames,1);
A = 10*ones(frames,1);
for i=floor(L/2):d:frames-(floor(L/2)-d)
    snippet = motion(i-floor(L/2)+1:i+floor(L/2)-d);
    deviation = (snippet-mean(snippet)).^2;
    E(i) = sqrt(mean(deviation));
    A(i) = mean(snippet);
end
% E(A>=.5) = .5;