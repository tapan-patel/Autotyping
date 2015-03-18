function threshold = GetThreshold(Info)
% Determines the threshold using video footage of an empty box
% Read in a movie file
abs_mv_path = Info.filename;
if(isempty(which('mmread')))
    addpath('../mmread');
end

disp(['Processing ' abs_mv_path]);
% If number of frames was not detected,read in the last frame to determine the number of frames



frames = mmcount(abs_mv_path);

times = zeros(frames,1);
%% Process f frames at a time
thresh_mat = Inf*ones(frames,'single');

f = 30;
start_idx = Info.start_idx;
T = [start_idx+1:f:frames frames];
for k =1:length(T)-1
   
        V = mmread(abs_mv_path,T(k):T(k+1)-1); V = V(end);
   
    n = length(V.frames);
    % Convert to gray scale & resize
    for j=1:n
        I = rgb2gray(V.frames(j).cdata);
        V.frames(j).cdata = I;
    end
    for j=1:n
        i = T(k)+j-1;
        times(i) = V(end).times(j);
        
        if(mod(i-start_idx,1000)==0)
            disp(['     ' abs_mv_path ': ' num2str(i-start_idx) ' of ' num2str(frames-start_idx) ' frames processed.']);
        end
        % Compute the graythresh of image difference of each pair of
        % frames
        for m=j+1:n
            p = T(k)+m-1;
                        I1 = V.frames(j).cdata;
                        I2 = V.frames(m).cdata;
                        D = imabsdiff(I1,I2);
% %                         t = 255*graythresh(D);
%                         thresh_mat(i,p) = floor(t);
%                         thresh_mat(p,i) = floor(t);
                        thresh_mat(i,p) = floor(sum(sum(D)));
                        thresh_mat(p,i) = thresh_mat(i,p);
%                         
%                         
%             I1 = V.frames(j).cdata; 
%             I2 = V.frames(m).cdata;
%             D = imabsdiff(I1,I2);
%             thresh_mat(i,p) = mean(mean(D))*255;
%             thresh_mat(p,i) = thresh_mat(i,p);
        end
    end
end
thresh_mat = thresh_mat(1:frames,1:frames);

threshold = mean(thresh_mat(thresh_mat~=Inf))+std(thresh_mat(thresh_mat~=Inf));